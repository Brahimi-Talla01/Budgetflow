class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

// Alias pour compatibilité
typedef OnboardingPageModel = OnboardingData;

// Liste des 3 pages d'onboarding
final List<OnboardingData> onboardingPages = [
  OnboardingData(
    image: 'assets/images/illustre1.png',
    title: 'Prenez le contrôle de vos finances',
    description:
        'Suivez vos dépenses et vos revenus en temps réel. Gérez votre budget facilement et gardez toujours une vue claire sur vos finances.',
  ),
  OnboardingData(
    image: 'assets/images/illustre2.png',
    title: 'Analysez vos dépenses',
    description:
        'Visualisez vos habitudes de consommation avec des graphiques interactifs. Identifiez où va votre argent.',
  ),
  OnboardingData(
    image: 'assets/images/ill3.png',
    title: 'Atteignez vos objectifs',
    description:
        'Créez des projets et suivez leur progression. Recevez des alertes pour rester dans votre budget.',
  ),
];
