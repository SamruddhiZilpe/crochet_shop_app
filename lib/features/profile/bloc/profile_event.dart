abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String email;

  UpdateProfileEvent(this.name, this.email);
}

class UploadProfileImageEvent extends ProfileEvent {
  final String imagePath;

  UploadProfileImageEvent(this.imagePath);
}
