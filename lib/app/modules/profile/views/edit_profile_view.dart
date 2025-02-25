import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:twitter_alternative/app/controllers/profile_controller.dart';
import 'package:twitter_alternative/app/theme/color_theme.dart';
import 'package:twitter_alternative/core/widgets/custom_button.dart';
import 'package:twitter_alternative/core/widgets/custom_text_field.dart';
import 'package:twitter_alternative/core/widgets/loading_indicator.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    // Setup profile editing form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setupProfileEditing();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isSubmitting.value) {
          return const LoadingIndicator(
            message: 'Updating profile...',
          );
        }

        return SafeArea(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message if any
                  if (controller.errorMessage.value.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: ColorTheme.error),
                      ),
                    ),

                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Obx(() {
                          final user = controller.profileUser.value;
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: controller.selectedAvatar.value !=
                                    null
                                ? FileImage(controller.selectedAvatar.value!)
                                : controller.selectedAvatarBytes.value != null
                                    ? MemoryImage(controller.selectedAvatarBytes
                                        .value!) as ImageProvider
                                    : user?.avatarUrl != null
                                        ? NetworkImage(user!.avatarUrl!)
                                        : null,
                            child: controller.selectedAvatar.value == null &&
                                    controller.selectedAvatarBytes.value ==
                                        null &&
                                    user?.avatarUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          );
                        }),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: ColorTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'gallery') {
                                  if (kIsWeb) {
                                    controller.pickAvatarWeb();
                                  } else {
                                    controller.pickAvatar();
                                  }
                                } else if (value == 'camera' && !kIsWeb) {
                                  controller.takePhoto();
                                } else if (value == 'remove') {
                                  controller.removeAvatar();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'gallery',
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_library),
                                      SizedBox(width: 8),
                                      Text('Gallery'),
                                    ],
                                  ),
                                ),
                                if (!kIsWeb)
                                  const PopupMenuItem(
                                    value: 'camera',
                                    child: Row(
                                      children: [
                                        Icon(Icons.camera_alt),
                                        SizedBox(width: 8),
                                        Text('Camera'),
                                      ],
                                    ),
                                  ),
                                if (controller.selectedAvatar.value != null ||
                                    controller.selectedAvatarBytes.value !=
                                        null ||
                                    controller.profileUser.value?.avatarUrl !=
                                        null)
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 8),
                                        Text('Remove'),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Username field
                  CustomTextField(
                    label: 'Username',
                    hint: 'Enter your username',
                    controller: controller.usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.contains(' ')) {
                        return 'Username cannot contain spaces';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Display name field
                  CustomTextField(
                    label: 'Display Name',
                    hint: 'Enter your display name',
                    controller: controller.displayNameController,
                  ),
                  const SizedBox(height: 16),

                  // Bio field
                  CustomTextField(
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    controller: controller.bioController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.updateProfile();
                      }
                    },
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: 16),

                  // Cancel button
                  CustomButton(
                    text: 'Cancel',
                    onPressed: () => Get.back(),
                    type: ButtonType.outline,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
