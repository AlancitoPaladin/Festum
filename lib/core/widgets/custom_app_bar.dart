import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/core/widgets/app_remote_image.dart';
import 'package:festum/core/services/provider_branding_service.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: actions ?? const <Widget>[_ProviderAppBarAvatar()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ProviderAppBarAvatar extends StatelessWidget {
  const _ProviderAppBarAvatar();

  @override
  Widget build(BuildContext context) {
    final ProviderBrandingService brandingService =
        locator<ProviderBrandingService>();

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: ListenableBuilder(
        listenable: brandingService,
        builder: (BuildContext context, Widget? child) {
          final String imageUrl = brandingService.logoUrl;
          return CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.backgroundElevated,
            child: imageUrl.trim().isEmpty
                ? const Icon(
                    Icons.storefront_outlined,
                    size: 18,
                    color: AppColors.secondaryText,
                  )
                : ClipOval(
                    child: AppRemoteImage(
                      imageUrl: imageUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        width: 36,
                        height: 36,
                        color: AppColors.backgroundElevated,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
