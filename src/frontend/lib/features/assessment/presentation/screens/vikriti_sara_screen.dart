import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/widgets/primary_button.dart';

class VikritiSaraQuestion {
  final String title;
  final String sanskritCategory;
  final String description;
  final List<VikritiSaraOption> options;

  const VikritiSaraQuestion({
    required this.title,
    required this.sanskritCategory,
    required this.description,
    required this.options,
  });
}

class VikritiSaraOption {
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;
  final IconData icon;

  const VikritiSaraOption({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
  });
}

class ChatMessage {
  final String sender; // 'bot', 'user', or 'typing'
  final String text;
  final String? category;

  ChatMessage({required this.sender, required this.text, this.category});
}

class VikritiSaraScreen extends StatefulWidget {
  const VikritiSaraScreen({super.key});

  @override
  State<VikritiSaraScreen> createState() => _VikritiSaraScreenState();
}

class _VikritiSaraScreenState extends State<VikritiSaraScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentQuestionIndex = 0;
  final List<ChatMessage> _messages = [];
  int? _selectedOptionIndex;
  bool _isTransitioning = false;

  final List<VikritiSaraQuestion> _questions = const [
    VikritiSaraQuestion(
      title: 'Active Dosha Imbalance (Vikriti Pariksha)',
      sanskritCategory: 'Vikriti Pariksha (Active Pathology)',
      description: 'Identifies transient deviations from baseline Prakriti caused by climate, stress, or diet. Select your current aggravated dosha spectrum:',
      options: [
        VikritiSaraOption(
          title: 'Pitta Dushti (Hyper-Heat & Acidity)',
          description: 'Hyperacidity, acid reflux, burning sensation, skin redness/eruptions, excessive thirst, and acute irritability.',
          badgeText: 'PITTA IMBALANCE',
          badgeColor: Color(0xFFE26D45),
          icon: LucideIcons.flame,
        ),
        VikritiSaraOption(
          title: 'Vata Dushti (Dryness, Stiffness & Pain)',
          description: 'Aching joints, lower back stiffness, constipation, gaseous distension, ungrounded anxiety, and disturbed sleep.',
          badgeText: 'VATA IMBALANCE',
          badgeColor: Color(0xFF6B8AFD),
          icon: LucideIcons.wind,
        ),
        VikritiSaraOption(
          title: 'Kapha Dushti (Sluggishness & Heaviness)',
          description: 'Mucus congestion, bodily heaviness, excessive daytime sleepiness, slow digestion, and water retention.',
          badgeText: 'KAPHA IMBALANCE',
          badgeColor: Color(0xFF3B9B78),
          icon: LucideIcons.droplet,
        ),
        VikritiSaraOption(
          title: 'Vata-Pitta Sannipata (Combined Imbalance)',
          description: 'Simultaneous dryness with burning sensations and erratic metabolic flare-ups.',
          badgeText: 'DUAL DOSHA',
          badgeColor: Color(0xFFD97706),
          icon: LucideIcons.refresh_cw,
        ),
      ],
    ),
    VikritiSaraQuestion(
      title: 'Tissue Integrity & Vitality (Sara Pariksha)',
      sanskritCategory: 'Sara Pariksha (Tissue Integrity & Ojas)',
      description: 'Assesses constitutional strength (Bala) and the functional resilience of the seven anatomical dhatus. Select your overall tissue excellence level:',
      options: [
        VikritiSaraOption(
          title: 'Pravara Sara (High / Optimal Vitality)',
          description: 'Excellent endurance, vibrant skin luster, robust immunity (Ojas), dense bone structure, and rapid recovery.',
          badgeText: 'UTTAMA • OPTIMAL',
          badgeColor: Color(0xFF2563EB),
          icon: LucideIcons.star,
        ),
        VikritiSaraOption(
          title: 'Madhyama Sara (Moderate Vitality)',
          description: 'Average muscular tone and stamina, normal immunity, standard resilience against seasonal illnesses.',
          badgeText: 'MADHYAMA • MEDIUM',
          badgeColor: Color(0xFF4F46E5),
          icon: LucideIcons.sliders_horizontal,
        ),
        VikritiSaraOption(
          title: 'Avara Sara (Suboptimal / Deficient Vitality)',
          description: 'Prone to recurrent fatigue, low appetite resilience, weak muscular grip, and susceptibility to chronic ailments.',
          badgeText: 'AVARA • LOW',
          badgeColor: Color(0xFFDC2626),
          icon: LucideIcons.battery_warning,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentQuestionWithTyping();
  }

  void _loadCurrentQuestionWithTyping() {
    if (_currentQuestionIndex < _questions.length) {
      final q = _questions[_currentQuestionIndex];
      setState(() {
        _selectedOptionIndex = null;
        _isTransitioning = false;
        _messages.add(ChatMessage(sender: 'typing', text: ''));
      });
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _messages.removeLast();
          _messages.add(ChatMessage(
            sender: 'bot',
            text: '${q.title}\n\n${q.description}',
            category: q.sanskritCategory,
          ));
        });
        _scrollToBottom();
      });
    }
  }

  void _handleOptionSelected(int optionIndex) {
    setState(() {
      _selectedOptionIndex = optionIndex;
    });
  }

  void _onConfirmSelection() {
    if (_selectedOptionIndex == null || _isTransitioning) return;

    final activeQuestion = _questions[_currentQuestionIndex];
    final selectedOption = activeQuestion.options[_selectedOptionIndex!];

    setState(() {
      _isTransitioning = true;
      _selectedOptionIndex = null;
      _messages.add(ChatMessage(
        sender: 'user',
        text: selectedOption.title,
      ));
      _messages.add(ChatMessage(sender: 'typing', text: ''));
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
      });

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
        });
        _loadCurrentQuestionWithTyping();
      } else {
        setState(() {
          _messages.add(ChatMessage(
            sender: 'bot',
            text: 'Thank you! Your Vikriti and Sara assessment is complete. Proceeding to evaluate your complaints.',
          ));
        });
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.presentComplaint);
          }
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;
    final fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final muted = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    final activeQuestion = (!_isTransitioning &&
        _currentQuestionIndex < _questions.length &&
        _messages.isNotEmpty &&
        _messages.last.sender != 'typing')
        ? _questions[_currentQuestionIndex]
        : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vikriti Sara Pariksha', style: AppTextStyles.titleMedium.copyWith(color: fg, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),

      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 260.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                if (message.sender == 'typing') {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.bot, size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16).copyWith(topLeft: const Radius.circular(0)),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Text('Thinking...', style: AppTextStyles.bodySmall.copyWith(color: muted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final isBot = message.sender == 'bot';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Row(
                    mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBot) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.bot, size: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: isBot
                                ? (isDark ? AppColors.surfaceDark : AppColors.surfaceElevated)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(16).copyWith(
                              topLeft: isBot ? const Radius.circular(0) : const Radius.circular(16),
                              topRight: !isBot ? const Radius.circular(0) : const Radius.circular(16),
                            ),
                            border: isBot ? Border.all(color: isDark ? AppColors.borderDark : AppColors.border) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.category != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF132F6E) : AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    message.category!,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isDark ? AppColors.highlight : AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                message.text,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isBot ? fg : Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isBot) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.user, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: activeQuestion != null
          ? Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 50),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceElevated,
          border: Border(top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08), offset: const Offset(0, -4), blurRadius: 10)],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select your Answer:', style: AppTextStyles.labelSmall.copyWith(color: muted, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ...List.generate(activeQuestion.options.length, (optIdx) {
                final opt = activeQuestion.options[optIdx];
                final bool isSelected = _selectedOptionIndex == optIdx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => _handleOptionSelected(optIdx),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariant.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(opt.icon, size: 16, color: opt.badgeColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.title,
                                  style: AppTextStyles.labelMedium.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                                Text(
                                  opt.description,
                                  style: AppTextStyles.bodySmall.copyWith(color: muted, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(LucideIcons.check_check, size: 16, color: AppColors.primary)
                          else
                            const Icon(LucideIcons.circle, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              PrimaryButton(
                label: _currentQuestionIndex == _questions.length - 1 ? tr('continue') : tr('continue'),
                leadingIcon: LucideIcons.arrow_right,
                onPressed: _selectedOptionIndex != null ? _onConfirmSelection : () {},
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }
}