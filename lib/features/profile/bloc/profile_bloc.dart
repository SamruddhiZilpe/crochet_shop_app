import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../data/models/user_profile_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_loadProfile);
    on<UpdateProfileEvent>(_updateProfile);
    on<UploadProfileImageEvent>(_uploadImage);
  }

  Future<void> _loadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _updateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await repository.updateProfile(name: event.name, email: event.email);

    add(LoadProfileEvent());
  }

  Future<void> _uploadImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await repository.uploadImage(File(event.imagePath));

    add(LoadProfileEvent());
  }
}
