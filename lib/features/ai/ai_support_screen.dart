import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:neomama/models/baby_profile.dart';
import 'package:neomama/services/ai_service.dart';

import 'package:neomama/core/theme/neo_background.dart';
import 'package:neomama/core/theme/neo_card.dart';
import 'package:neomama/core/theme/app_colors.dart';
import 'package:neomama/core/utils/color_ext.dart';
import 'package:neomama/l10n/app_strings.dart';

class AiSupportScreen extends StatefulWidget {
  final BabyProfile baby;

  const AiSupportScreen({super.key, required this.baby});

  @override
  State<AiSupportScreen> createState() => _AiSupportScreenState();
}

class _AiSupportScreenState extends State<AiSupportScreen> {
  final _ctrl = TextEditingController();
  final _listCtrl = ScrollController();

  final List<_Msg> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isNotEmpty) return;
    _messages.add(
      _Msg(
        fromMe: false,
        text: AppStrings.t(
          context,
          'ai_welcome',
          vars: {'name': widget.baby.name},
        ),
      ),
    );
    _scrollToBottom(jump: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_listCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listCtrl.hasClients) return;
      final pos = _listCtrl.position.maxScrollExtent;
      if (jump) {
        _listCtrl.jumpTo(pos);
      } else {
        _listCtrl.animateTo(
          pos,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatBirthDate(Object? d) {
    if (d == null) return '-';
    if (d is DateTime) {
      final y = d.year.toString().padLeft(4, '0');
      final m = d.month.toString().padLeft(2, '0');
      final day = d.day.toString().padLeft(2, '0');
      return '$y-$m-$day';
    }
    return d.toString();
  }

  
  String _stripMarkdown(String s) {
    var out = s;

    
    out = out.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s+', multiLine: true), '');

    
    out = out.replaceAll('**', '');
    out = out.replaceAll('__', '');
    out = out.replaceAll('`', '');

    
    out = out.replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '• ');

    
    out = out.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return out.trim();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (_sending) return;
    if (text.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _sending = true;
      _messages.add(_Msg(fromMe: true, text: text));
      _ctrl.clear();
    });
    _scrollToBottom();

    
    final typingIndex = _messages.length;
    setState(() {
      _messages.add(_Msg(
        fromMe: false,
        text: AppStrings.t(context, 'ai_typing'),
        kind: _MsgKind.typing,
      ));
    });
    _scrollToBottom();

    try {
      final code = Localizations.localeOf(context).languageCode;
      final prompt = StringBuffer()
        ..writeln(AppStrings.byCode(code, 'ai_prompt_system'))
        ..writeln(AppStrings.byCode(code, 'ai_prompt_language'))
        ..writeln(AppStrings.byCode(code, 'ai_prompt_format'))
        ..writeln(AppStrings.byCode(code, 'ai_prompt_safety'))
        ..writeln(AppStrings.byCode(code, 'ai_prompt_tone'))
        ..writeln("")
        ..writeln(
          AppStrings.byCode(
            code,
            'ai_prompt_baby_name',
            vars: {'name': widget.baby.name},
          ),
        )
        ..writeln(
          AppStrings.byCode(
            code,
            'ai_prompt_birth_date',
            vars: {'date': _formatBirthDate(widget.baby.birthDate)},
          ),
        )
        ..writeln("")
        ..writeln(AppStrings.byCode(code, 'ai_prompt_question'))
        ..writeln(text);

      final rawReply = await AiService.instance.sendMessage(prompt.toString());
      final reply = _stripMarkdown(rawReply);

      if (!mounted) return;
      setState(() {
        if (typingIndex >= 0 && typingIndex < _messages.length) {
          _messages[typingIndex] = _Msg(fromMe: false, text: reply);
        } else {
          _messages.add(_Msg(fromMe: false, text: reply));
        }
      });
      _scrollToBottom();
    } catch (e, st) {
      if (kDebugMode) {
        
        print('AiSupportScreen _send error: $e');
        
        print(st);
      }

      if (!mounted) return;
      setState(() {
        final msg = AppStrings.t(context, 'ai_error');
        if (typingIndex >= 0 && typingIndex < _messages.length) {
          _messages[typingIndex] = _Msg(fromMe: false, text: msg, kind: _MsgKind.error);
        } else {
          _messages.add(_Msg(fromMe: false, text: msg, kind: _MsgKind.error));
        }
      });
      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return NeoBackground(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.t(
              context,
              'ai_chat_title',
              vars: {'name': widget.baby.name},
            ),
            style: t.titleLarge,
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: NeoCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.o(0.20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.ink.o(0.85),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t(context, 'ai_support_title'),
                              style: t.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.t(context, 'ai_support_desc'),
                              style: t.bodySmall?.copyWith(
                                color: AppColors.inkSoft.o(0.85),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _listCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) => _Bubble(msg: _messages[i]),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: NeoCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            onChanged: (_) => setState(() {}),
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: AppStrings.t(context, 'ai_hint'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: (_sending || _ctrl.text.trim().isEmpty) ? null : _send,
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MsgKind { normal, typing, error }

class _Msg {
  final bool fromMe;
  final String text;
  final _MsgKind kind;

  const _Msg({
    required this.fromMe,
    required this.text,
    this.kind = _MsgKind.normal,
  });
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final align = msg.fromMe ? Alignment.centerRight : Alignment.centerLeft;

    final bool isTyping = msg.kind == _MsgKind.typing;
    final bool isError = msg.kind == _MsgKind.error;

    final Color bg = msg.fromMe
        ? AppColors.primary.o(0.55)
        : (isError
            ? cs.errorContainer.o(0.92)
            : AppColors.surface.o(0.78));

    final Color fg = msg.fromMe
        ? AppColors.ink
        : (isError ? cs.onErrorContainer : AppColors.ink);

    final BorderRadius radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(msg.fromMe ? 18 : 8),
      bottomRight: Radius.circular(msg.fromMe ? 8 : 18),
    );

    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: () async {
          final text = msg.text.trim();
          if (text.isEmpty) return;

          await Clipboard.setData(ClipboardData(text: text));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.t(context, 'copied'))),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(
              color: (msg.fromMe
                      ? AppColors.border.o(0.8)
                      : cs.outlineVariant.o(0.22))
                  .o(0.9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.o(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: t.bodyMedium?.copyWith(
              color: fg,
              height: 1.32,
              fontStyle: isTyping ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}
