const products = [
  { id: 'p-1', name: 'AeroFlex Smartwatch', category: 'Wearables', price: 249, originalPrice: 299, rating: 4.8, reviewCount: 481, imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=900&q=80', stock: 24, isFeatured: true },
  { id: 'p-2', name: 'Nova Wireless Headphones', category: 'Audio', price: 189, originalPrice: 239, rating: 4.7, reviewCount: 312, imageUrl: 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=900&q=80', stock: 18, isFeatured: true },
  { id: 'p-3', name: 'Luma Studio Lamp', category: 'Home', price: 129, originalPrice: 169, rating: 4.6, reviewCount: 198, imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=900&q=80', stock: 14, isFeatured: false },
  { id: 'p-4', name: 'TerraCarry Backpack', category: 'Travel', price: 149, originalPrice: 199, rating: 4.9, reviewCount: 219, imageUrl: 'https://images.unsplash.com/photo-1491637639811-60e2756cc1c7?auto=format&fit=crop&w=900&q=80', stock: 38, isFeatured: true },
];

const categories = ['Mobiles', 'Electronics', 'Fashion', 'Shoes', 'Home', 'Furniture', 'TV & Appliances', 'Beauty', 'Toys', 'Grocery', 'Pharmacy/Wellness', 'Travel/Flights', 'Gift Cards', 'Rewards', 'Minutes'];

module.exports = { products, categories };
