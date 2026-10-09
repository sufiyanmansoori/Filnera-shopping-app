library;

export 'data/datasources/product_local_datasource.dart';
export 'data/datasources/product_remote_datasource.dart';
export 'data/models/category_model.dart';
export 'data/models/product_model.dart';
export 'data/repositories/product_repository_impl.dart';

export 'domain/entities/product_entity.dart';
export 'domain/usecases/get_product_detail_usecase.dart';
export 'domain/usecases/get_products_usecase.dart';

export 'presentation/controllers/product_controller.dart';
export 'presentation/providers/category_provider.dart';
export 'presentation/providers/product_provider.dart';

export 'presentation/screens/category_products_screen.dart';
export 'presentation/screens/product_detail_screen.dart';
export 'presentation/screens/product_list_screen.dart';
export 'presentation/screens/similar_products_screen.dart';

export 'presentation/widgets/product_actions_widget.dart';
export 'presentation/widgets/product_card_widget.dart';
export 'presentation/widgets/product_image_gallery_widget.dart';
export 'presentation/widgets/product_offers_widget.dart';
export 'presentation/widgets/product_price_widget.dart';
export 'presentation/widgets/product_shipping_widget.dart';
export 'presentation/widgets/product_specifications_widget.dart';
export 'presentation/widgets/seller_info_widget.dart';
export 'presentation/widgets/variant_selector_widget.dart';
