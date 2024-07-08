import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final Function()? onSignIn;
  final Function()? onSignUp;

  const SplashScreen({
    super.key,
    this.onSignIn,
    this.onSignUp,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashModel _model;
  final animationsMap = <String, AnimationInfo>{};

  Function()? get onSignIn => widget.onSignIn;
  Function()? get onSignUp => widget.onSignUp;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashModel());

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 400.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 400.0.ms,
            duration: 400.0.ms,
            begin: const Offset(0.0, 30.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'rowOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 300.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 300.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.6, 0.6),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 50, 0, 0),
                child: Container(
                  width: double.infinity,
                  height: 500,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBackground,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.asset(
                        'assets/images/doracle2.png',
                      ).image,
                    ),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 80, 0, 0),
                          child: Container(
                            width: 300,
                            height: 100,
                            decoration: const BoxDecoration(),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/doracle_logo_1@2x.webp',
                                width: 300,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              44, 8, 44, 0),
                          child: Text(
                            'Ever wished you could peer into the future? Well, now you can—with a twist! Doracle is your go-to \ncanine oracle. Let\'s get started!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelMedium,
                          ).animateOnPageLoad(
                              animationsMap['textOnPageLoadAnimation']!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 44),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 8, 16),
                        child: ElevatedButton(
                          onPressed: onSignIn,
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).textTheme.bodyLarge?.color,
                            backgroundColor: AppTheme.secondaryBackground,
                            minimumSize: const Size(230, 52),
                            elevation: 0,
                            side: const BorderSide(
                              color: AppTheme.alternateColor,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 16),
                        child: ElevatedButton(
                          onPressed: onSignUp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).textTheme.titleSmall?.color,
                            backgroundColor: AppTheme.primaryColor,
                            minimumSize: const Size(230, 52),
                            elevation: 3,
                            side: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  letterSpacing: 0,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animateOnPageLoad(animationsMap['rowOnPageLoadAnimation']!),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashModel extends FlutterFlowModel<SplashScreen> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
