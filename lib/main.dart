import 'package:flutter/material.dart';

// Главная функция
void main() {
  runApp(MyApp());
}

class ShopRouterDelegate extends RouterDelegate<NavigationState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavigationState> {
  //состояние при запуске - список категорий
  String? _category;
  int? _product;
  bool _notFound = false;

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Future<void> setNewRoutePath(NavigationState configuration) async {
    _category = configuration.category;
    _product = configuration.product;
    _notFound = configuration.notFound;
  }

  @override
  NavigationState get currentConfiguration => NavigationState(
    category: _category,
    product: _product,
    notFound: _notFound,
  );

  void gotoCategoriesList({bool useNotify = true}) {
    _category = null;
    _product = null;
    _notFound = false;
    if (useNotify) {
      notifyListeners();
    }
  }

  void gotoProductsList(String category, {bool useNotify = true}) {
    _category = category;
    _product = null;
    _notFound = false;
    if (useNotify) {
      notifyListeners();
    }
  }

  void gotoProductInfo(String category, int product, {bool useNotify = true}) {
    _category = category;
    _product = product;
    _notFound = false;
    if (useNotify) {
      notifyListeners();
    }
  }

  void gotoNotFound({bool useNotify = true}) {
    _notFound = true;
    if (useNotify) {
      notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) => Navigator(
    onDidRemovePage: (page) {
      switch (page.name) {
        case 'category_list':
        //здесь перехода нет, это первая страница
        case 'product_list':
          gotoCategoriesList();
        case 'product_detail':
          if (_category != null) {
            gotoProductsList(_category!);
          }
      }
    },
    pages: [
      if (_notFound)
        MaterialPage(child: NotFoundPage())
      else ...[
        MaterialPage(
          child: CategoryListPage(
            showCategory: (category) => gotoProductsList(category),
          ),
          name: 'category_list',
        ),
        if (_category != null)
          MaterialPage(
            child: ProductListPage(
              category: _category!,
              showProduct: (category, product) =>
                  gotoProductInfo(category, product),
            ),
            name: 'product_list',
          ),
        if (_product != null)
          MaterialPage(
            child: ProductDetailPage(
              product: categoryData[_category]![_product!],
              gotoProductList: () => gotoProductsList(_category!),
            ),
            name: 'product_detail',
          ),
      ],
    ],
  );
}

class ShopRouteProvider extends PlatformRouteInformationProvider {
  ShopRouteProvider({required super.initialRouteInformation});

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    super.routerReportsNewRouteInformation(routeInformation, type: type);
    print('NEW ROUTE: ${routeInformation.uri.path}');
  }
}

class ShopRouteParser extends RouteInformationParser<NavigationState> {
  @override
  Future<NavigationState> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    try {
      final uri = routeInformation.uri;
      if (uri.pathSegments.isEmpty) return NavigationState.categoryList();
      if (uri.pathSegments.first == 'products' &&
          uri.pathSegments.length == 2) {
        return NavigationState.productList(uri.pathSegments.last);
      }
      if (uri.pathSegments.first == 'product' && uri.pathSegments.length == 3) {
        String category = uri.pathSegments[1];
        return NavigationState(
          category: category,
          product: int.parse(uri.pathSegments[2]),
        );
      }
    } on Object catch (e) {
      //not found
    }
    return NavigationState(notFound: true);
  }

  @override
  RouteInformation restoreRouteInformation(NavigationState configuration) {
    if (configuration.isCategoryList) {
      return RouteInformation(uri: Uri.parse('/'));
    }
    if (configuration.isProductList) {
      return RouteInformation(
        uri: Uri.parse('/products/${configuration.category}'),
      );
    }
    return RouteInformation(
      uri: Uri.parse(
        '/product/${configuration.category}/${configuration.product}',
      ),
    );
  }
}

class NavigationState {
  final int? product;
  final String? category;
  final bool notFound;

  NavigationState({this.product, this.category, this.notFound = false});

  bool get isCategoryList => product == null && category == null;

  bool get isProductList => product == null && category != null;

  bool get isProduct => product != null && category != null;

  NavigationState.categoryList() : this();

  NavigationState.productList(String category) : this(category: category);

  NavigationState.productInfo(String category, int product)
    : this(category: category, product: product);
}

// Основное приложение
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Сладости',
    theme: ThemeData(primarySwatch: Colors.pink),
    routerDelegate: ShopRouterDelegate(),
    routeInformationParser: ShopRouteParser(),
    routeInformationProvider: ShopRouteProvider(
      initialRouteInformation: RouteInformation(uri: Uri.parse('/')),
    ),
  );
}

// Страница списка категорий
class CategoryListPage extends StatelessWidget {
  final ValueSetter<String> showCategory;

  CategoryListPage({required this.showCategory, super.key});

  final List<String> categories = categoryData.keys.toList();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Категории сладостей')),
        body: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(categories[index]),
              onTap: () => showCategory(categories[index]),
            );
          },
        ),
      ),
    );
  }
}

// Страница списка товаров в категории
class ProductListPage extends StatelessWidget {
  final String category;
  final List<Map<String, String>> products;
  final Function(String, int) showProduct;

  ProductListPage({
    super.key,
    required this.category,
    required this.showProduct,
  }) : products = categoryData[category]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category - Товары')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']!),
            subtitle: Text(products[index]['description']!),
            onTap: () => showProduct(category, index),
          );
        },
      ),
    );
  }
}

// Страница описания товара
class ProductDetailPage extends StatelessWidget {
  final Map<String, String> product;

  final VoidCallback gotoProductList;

  const ProductDetailPage({
    required this.product,
    required this.gotoProductList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name']!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(product['description']!, style: const TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: gotoProductList,
              child: const Text('К списку товаров'),
            ),
            ElevatedButton(
              onPressed: () =>
                  (Router.of(context).routerDelegate as ShopRouterDelegate)
                      .gotoCategoriesList(),
              child: const Text('К списку категорий'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Page is not found')));
}

// Описание категорий и товаров
const Map<String, List<Map<String, String>>> categoryData = {
  'Шоколад': [
    {
      'name': 'Аленка',
      'description': 'Классический молочный шоколад с нежной текстурой.',
    },
    {
      'name': 'Три корочки',
      'description': 'Шоколад с хрустящими вафельными корочками.',
    },
    {
      'name': 'Барни',
      'description': 'Шоколад с начинкой из мягкого молочного крема.',
    },
  ],
  'Конфеты': [
    {
      'name': 'Мишки на севере',
      'description': 'Жевательные конфеты с фруктовым вкусом.',
    },
    {
      'name': 'Вдохновение',
      'description': 'Шоколадные конфеты с карамельной начинкой.',
    },
    {
      'name': 'Карамельки',
      'description': 'Карамельные конфеты с разными вкусами.',
    },
  ],
  'Печенье': [
    {
      'name': 'Юбилейное',
      'description': 'Традиционное печенье с шоколадной глазурью.',
    },
    {
      'name': 'Песочное',
      'description': 'Легкое и рассыпчатое песочное печенье.',
    },
    {'name': 'Орео', 'description': 'Популярное печенье с кремовой начинкой.'},
  ],
};
