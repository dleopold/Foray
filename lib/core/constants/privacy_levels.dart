enum PrivacyLevel {
  private('Private', 'Only you can see'),
  foray('Foray', 'Visible to foray participants'),
  publicExact('Public', 'Visible to everyone'),
  publicObscured('Obscured', 'Public with approximate location');

  const PrivacyLevel(this.label, this.description);

  final String label;
  final String description;
}
