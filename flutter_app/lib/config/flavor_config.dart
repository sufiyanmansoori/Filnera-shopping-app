enum AppFlavor { development, staging, production }

class FlavorConfig {
  const FlavorConfig._();
  static const AppFlavor flavor = AppFlavor.development;
}
