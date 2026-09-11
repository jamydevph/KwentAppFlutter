import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kwentappflutter/core/common/common.dart';
import 'package:kwentappflutter/core/resources/constants.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/core/theme/app_theme.dart';
import 'package:kwentappflutter/core/utils/image_bytes.dart';
import 'package:kwentappflutter/core/utils/image_picking.dart';
import 'package:kwentappflutter/core/utils/validators.dart';
import 'package:kwentappflutter/data/models/profile.dart';
import 'package:kwentappflutter/ui/auth/auth_viewmodel.dart';
import 'package:kwentappflutter/ui/profile/profile_state.dart';
import 'package:kwentappflutter/ui/profile/profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late final ProfileViewModel _viewModel;
  var _autovalidate = AutovalidateMode.disabled;
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ProfileViewModel>();
    _emailController.text = context.read<AuthViewModel>().user?.email ?? '';
    _hydrate(notify: false);
    _viewModel.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChanged);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onStateChanged() => _hydrate();

  void _hydrate({bool notify = true}) {
    if (_hydrated) return;

    final state = _viewModel.state;
    if (state is! ProfileLoaded) return;

    _hydrated = true;
    _nameController.text = state.profile.name;

    if (notify && mounted) setState(() {});
  }

  Future<void> _saveName() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    final message = await _viewModel.saveName(_nameController.text.trim());
    _report(message);
  }

  Future<void> _changePhoto() async {
    final picked = await pickImages(slots: 1);
    if (!mounted) return;

    if (picked.isEmpty) {
      if (picked.skipped) {
        CommonSnackbar.show(context, Strings.someImagesSkipped);
      }
      return;
    }

    final bytes = picked.images.first;

    final message = await _viewModel.changeAvatar(
      bytes: bytes,
      extension: imageExtensionFor(bytes) ?? Constants.defaultImageExtension,
    );
    _report(message);
  }

  Future<void> _removePhoto() async {
    final confirmed = await CommonConfirmDialog.show(
      context,
      title: Strings.removePhotoTitle,
      message: Strings.removePhotoMessage,
      confirmLabel: Strings.removePhoto,
    );

    if (!confirmed || !mounted) return;

    _report(await _viewModel.removeAvatar());
  }

  void _report(String? message) {
    if (!mounted) return;

    if (message != null) {
      CommonSnackbar.showError(context, message);
      return;
    }

    CommonSnackbar.show(context, Strings.profileUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileViewModel>().state;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.profileTitle)),
      body: switch (state) {
        ProfileLoading() => const CommonLoader(),
        ProfileError(:final message) => _ProfileFailed(
          message: message,
          onRetry: _viewModel.load,
        ),
        ProfileLoaded() => _content(state),
      },
    );
  }

  Widget _content(ProfileLoaded state) {
    final theme = Theme.of(context);

    final gutter = AppLayout.sideGutter(MediaQuery.sizeOf(context).width);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        gutter,
        AppSpacing.xl,
        gutter,
        AppSpacing.xl * 2,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.contentMaxWidth,
          ),
          child: Column(
            children: [
              _ProfileAvatar(
                profile: state.profile,
                isBusy: state.isChangingAvatar,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: state.isBusy ? null : _changePhoto,
                    child: const Text(Strings.changePhoto),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  TextButton(
                    onPressed: state.isBusy || state.profile.avatarUrl == null
                        ? null
                        : _removePhoto,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text(Strings.removePhoto),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: CommonTextField(
                  controller: _nameController,
                  label: Strings.nameLabel,
                  hint: Strings.nameHint,
                  enabled: !state.isBusy,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      Validators.notEmpty(value, Strings.nameRequired),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CommonTextField(
                controller: _emailController,
                label: Strings.emailLabel,
                enabled: false,
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Strings.emailLocked,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CommonPrimaryButton(
                label: Strings.save,
                isLoading: state.isSavingName,
                onPressed: state.isBusy ? null : _saveName,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                Strings.profileNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              const _LogOutButton(),
              const _DeleteAccountButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.isBusy});

  final Profile profile;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = profile.avatarUrl;
    final hasPhoto = url != null && url.isNotEmpty;

    return SizedBox(
      height: 96,
      width: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            foregroundImage: hasPhoto ? NetworkImage(url) : null,
            child: Text(
              initialsOf(profile.name),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          if (isBusy)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface.withValues(alpha: 0.72),
              ),
              child: const CommonLoader(size: 24),
            ),
        ],
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthViewModel>();

    return TextButton(
      onPressed: auth.isBusy ? null : auth.logout,
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
      child: auth.isBusy
          ? const CommonLoader(size: 16)
          : const Text(Strings.logOut),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthViewModel>();

    return TextButton(
      onPressed: auth.isBusy ? null : () => _confirmAndDelete(context),
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
      child: const Text(Strings.deleteAccount),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final auth = context.read<AuthViewModel>();

    final confirmed = await CommonConfirmDialog.show(
      context,
      title: Strings.deleteAccountTitle,
      message: Strings.deleteAccountMessage,
      confirmLabel: Strings.deleteAccount,
    );
    if (!confirmed) return;

    final ok = await auth.deleteAccount();
    if (!ok && context.mounted) {
      CommonSnackbar.showError(context, auth.formError ?? Strings.genericError);
    }
  }
}

class _ProfileFailed extends StatelessWidget {
  const _ProfileFailed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              Strings.profileLoadFailed,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text(Strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
