class AdContent {
  const AdContent({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.cta,
    this.category = 'All',
    this.badge = 'ADVERTISEMENT',
    this.discount = 'UP TO 60% OFF',
    this.brand = 'Manara Store',
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final String cta;
  final String category;
  final String badge;
  final String discount;
  final String brand;
}

const homeAds = [
  AdContent(
    title: 'Big savings on smart tech',
    subtitle: 'Upgrade your everyday setup from ₹999',
    imageUrl: 'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?auto=format&fit=crop&w=1400&q=85',
    cta: 'Shop electronics',
    category: 'Electronics',
    discount: 'UP TO 40% OFF',
    brand: 'Manara Tech',
  ),
  AdContent(
    title: 'Style that moves with you',
    subtitle: 'Fresh fashion picks up to 60% off',
    imageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1400&q=85',
    cta: 'Explore fashion',
    category: 'Fashion',
    discount: 'UP TO 60% OFF',
    brand: 'Manara Fashion',
  ),
  AdContent(
    title: 'Make home feel better',
    subtitle: 'Comfort, decor and appliances delivered fast',
    imageUrl: 'https://images.unsplash.com/photo-1556912167-f556f1f39fdf?auto=format&fit=crop&w=1400&q=85',
    cta: 'Shop home',
    category: 'Home',
    discount: 'FAST DELIVERY',
    brand: 'Manara Home',
  ),
  AdContent(
    title: 'Wellness starts today',
    subtitle: 'Everyday essentials with easy returns',
    imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=1400&q=85',
    cta: 'Shop wellness',
    category: 'Wellness',
    discount: 'HEALTH PICKS',
    brand: 'Manara Wellness',
  ),
  AdContent(
    title: 'Travel more, carry less',
    subtitle: 'Travel gear made for your next trip',
    imageUrl: 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&w=1400&q=85',
    cta: 'Shop travel',
    category: 'Travel',
    discount: 'TRAVEL READY',
    brand: 'Manara Travel',
  ),
];

const productReels = [
  'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1589003077984-894e133dabab?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1491637639811-60e2756cc1c7?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1523362624794-6c9b3600891f?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=700&q=85',
];

const dramaReels = [
  'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1511497584788-876760111969?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1500534623283-312aade485b7?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=700&q=85',
];

List<String> get productReelImages => productReels;
List<String> get dramaReelImages => dramaReels;
