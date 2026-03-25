import 'package:dio/dio.dart';
import 'package:festum/core/services/provider_branding_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/features/provider/models/business_info.dart';
import 'package:festum/features/provider/models/provider_asset_upload_response.dart';
import 'package:festum/features/provider/models/provider_business_profile.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';
import 'package:festum/features/provider/usecases/get_provider_business_profile_use_case.dart';
import 'package:festum/features/provider/usecases/save_provider_business_profile_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_business_logo_use_case.dart';
import 'package:festum/features/provider/usecases/upload_provider_business_photo_use_case.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

class ProviderBusinessInfoViewModel extends BaseViewModel {
  ProviderBusinessInfoViewModel(
    this._getProviderBusinessProfileUseCase,
    this._saveProviderBusinessProfileUseCase,
    this._uploadProviderBusinessLogoUseCase,
    this._uploadProviderBusinessPhotoUseCase,
    this._providerBusinessInfoStateService,
    this._providerBrandingService,
    this._providerReactivityService,
    this._imagePicker,
  );

  final GetProviderBusinessProfileUseCase _getProviderBusinessProfileUseCase;
  final SaveProviderBusinessProfileUseCase _saveProviderBusinessProfileUseCase;
  final UploadProviderBusinessLogoUseCase _uploadProviderBusinessLogoUseCase;
  final UploadProviderBusinessPhotoUseCase _uploadProviderBusinessPhotoUseCase;
  final ProviderBusinessInfoStateService _providerBusinessInfoStateService;
  final ProviderBrandingService _providerBrandingService;
  final ProviderReactivityService _providerReactivityService;
  final ImagePicker _imagePicker;

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController coverageAreaController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  final BusinessInfo _businessInfo = BusinessInfo();

  String? _errorMessage;
  bool _isUploadingAsset = false;
  bool _hasExistingProfile = false;
  bool _hasLoadedProfile = false;
  bool _didRefreshAfterAsset403 = false;

  BusinessInfo get businessInfo => _businessInfo;
  bool get isOnboardingRequired =>
      _providerBusinessInfoStateService.requiresBusinessInfo;
  String? get errorMessage => _errorMessage;
  bool get isUploadingAsset => _isUploadingAsset;
  bool get hasExistingProfile => _hasExistingProfile;
  bool get hasLoadedProfile => _hasLoadedProfile;

  Future<void> initialize() async {
    if (isBusy) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      final ProviderBusinessProfile profile =
          await _getProviderBusinessProfileUseCase();
      _applyProfile(profile);
      await _providerBrandingService.sync(
        businessName: profile.businessName,
        logoUrl: profile.logoUrl,
      );
      _didRefreshAfterAsset403 = false;
      _hasLoadedProfile = true;

      if (_hasMeaningfulBusinessData(profile)) {
        _hasExistingProfile = true;
        await _providerBusinessInfoStateService.completeBusinessInfo();
      }
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 404) {
        _hasLoadedProfile = true;
        _hasExistingProfile = false;
        _errorMessage = null;
        await _providerBusinessInfoStateService.resetBusinessInfoProgress();
        await _providerBrandingService.clear();
      } else {
        _errorMessage = ProviderBusinessRepository.mapApiError(error);
      }
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void updateName(String value) {
    _businessInfo.name = value;
    notifyListeners();
  }

  void updateLocation(String value) {
    _businessInfo.location = value;
    notifyListeners();
  }

  void updateCoverageArea(String value) {
    _businessInfo.coverageArea = value;
    notifyListeners();
  }

  void updateContactNumber(String value) {
    _businessInfo.contactNumber = value;
    notifyListeners();
  }

  void updateWhatsapp(String value) {
    _businessInfo.whatsapp = value;
    notifyListeners();
  }

  void updateInstagram(String value) {
    _businessInfo.instagram = value;
    notifyListeners();
  }

  void updateFacebook(String value) {
    _businessInfo.facebook = value;
    notifyListeners();
  }

  void updateWebsite(String value) {
    _businessInfo.website = value;
    notifyListeners();
  }

  Future<String?> saveProfile() async {
    setBusy(true);
    try {
      final ProviderBusinessProfile response =
          await _saveProviderBusinessProfileUseCase(_toProfile());
      _applyProfile(response);
      await _providerBrandingService.sync(
        businessName: response.businessName,
        logoUrl: response.logoUrl,
      );
      await _providerReactivityService.notifyBusinessChanged();
      _hasExistingProfile = true;
      await _providerBusinessInfoStateService.completeBusinessInfo();
      return null;
    } catch (error) {
      return ProviderBusinessRepository.mapApiError(error);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String?> pickLogo() async {
    return _uploadAsset(
      pickerAction: () =>
          _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85),
      uploadAction: _uploadProviderBusinessLogoUseCase.call,
      onUploaded: (String assetUrl) {
        _businessInfo.logoUrl = assetUrl;
      },
    );
  }

  Future<String?> addPhoto() async {
    return _uploadAsset(
      pickerAction: () =>
          _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85),
      uploadAction: _uploadProviderBusinessPhotoUseCase.call,
      onUploaded: (String assetUrl) {
        _businessInfo.photoUrls = List<String>.from(_businessInfo.photoUrls)
          ..add(assetUrl);
      },
    );
  }

  Future<void> retryLoad() async {
    await initialize();
  }

  Future<void> refreshSignedAssetsOnce() async {
    if (_didRefreshAfterAsset403 || isBusy) {
      return;
    }
    _didRefreshAfterAsset403 = true;
    await initialize();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    locationController.dispose();
    coverageAreaController.dispose();
    contactNumberController.dispose();
    whatsappController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  Future<String?> _uploadAsset({
    required Future<XFile?> Function() pickerAction,
    required Future<ProviderAssetUploadResponse> Function(String filePath)
    uploadAction,
    required void Function(String assetUrl) onUploaded,
  }) async {
    if (_isUploadingAsset) {
      return null;
    }

    try {
      final XFile? selectedFile = await pickerAction();
      if (selectedFile == null) {
        return null;
      }

      _isUploadingAsset = true;
      notifyListeners();

      final ProviderAssetUploadResponse response = await uploadAction(
        selectedFile.path,
      );
      final String assetUrl = response.assetUrl.trim();

      if (assetUrl.isEmpty) {
        return 'La API no devolvio una URL valida para el archivo.';
      }

      onUploaded(assetUrl);
      await _providerBrandingService.sync(
        businessName: _businessInfo.name,
        logoUrl: _businessInfo.logoUrl ?? '',
      );
      await _providerReactivityService.notifyBusinessChanged();
      return null;
    } catch (error) {
      return ProviderBusinessRepository.mapApiError(error);
    } finally {
      _isUploadingAsset = false;
      notifyListeners();
    }
  }

  ProviderBusinessProfile _toProfile() {
    return ProviderBusinessProfile(
      providerId: '',
      businessName: _businessInfo.name.trim(),
      location: _businessInfo.location.trim(),
      coverageArea: _businessInfo.coverageArea.trim(),
      contactNumber: _businessInfo.contactNumber.trim(),
      whatsapp: _businessInfo.whatsapp.trim(),
      instagram: _businessInfo.instagram.trim(),
      facebook: _businessInfo.facebook.trim(),
      website: _businessInfo.website.trim(),
      logoUrl: (_businessInfo.logoUrl ?? '').trim(),
      photoUrls: List<String>.from(_businessInfo.photoUrls),
    );
  }

  void _applyProfile(ProviderBusinessProfile profile) {
    _businessInfo.name = profile.businessName;
    _businessInfo.location = profile.location;
    _businessInfo.coverageArea = profile.coverageArea;
    _businessInfo.contactNumber = profile.contactNumber;
    _businessInfo.whatsapp = profile.whatsapp;
    _businessInfo.instagram = profile.instagram;
    _businessInfo.facebook = profile.facebook;
    _businessInfo.website = profile.website;
    _businessInfo.logoUrl = profile.logoUrl.isEmpty ? null : profile.logoUrl;
    _businessInfo.photoUrls = List<String>.from(profile.photoUrls);

    businessNameController.text = profile.businessName;
    locationController.text = profile.location;
    coverageAreaController.text = profile.coverageArea;
    contactNumberController.text = profile.contactNumber;
    whatsappController.text = profile.whatsapp;
    instagramController.text = profile.instagram;
    facebookController.text = profile.facebook;
    websiteController.text = profile.website;
  }

  bool _hasMeaningfulBusinessData(ProviderBusinessProfile profile) {
    return profile.businessName.trim().isNotEmpty ||
        profile.location.trim().isNotEmpty ||
        profile.coverageArea.trim().isNotEmpty ||
        profile.contactNumber.trim().isNotEmpty ||
        profile.logoUrl.trim().isNotEmpty ||
        profile.photoUrls.isNotEmpty;
  }
}
