import 'package:driveme/dependency_injector.dart';
import 'package:driveme/models/car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driveme/list/cars_list_bloc.dart';
import 'package:driveme/list/cars_list_page.dart';
import 'package:driveme/constants.dart';

import '../database/mock_car_data_provider.dart';
import '../database/mock_car_data_provider_error.dart';

void main() {
  setupLocator();
  var carsListBloc = locator<CarsListBloc>();

  //to test widgets you don't use test but testWidgets
  testWidgets(
      "Cars are displayed with summary details, and selected car is highlighted in blue.",
      (WidgetTester tester) async {
    // TODO 4: Inject and Load Mock Car Data
    carsListBloc.injectDataProviderForTest(MockCarDataProvider());

    // TODO 5: Load & Sort Mock Data for Verification
    CarsList cars = await MockCarDataProvider().loadCars();
    cars.items.sort(carsListBloc.alphabetiseItemsByTitleIgnoreCases);

    // TODO 6: Load and render Widget
    await tester.pumpWidget(ListPageWrapper());
    await tester.pump(Duration.zero);

    // TODO 7: Check Cars List's component's existence via key
    final carListKey = find.byKey(Key(CARS_LIST_KEY));
    expect(carListKey, findsOneWidget);

    // TODO 9: Call Verify Car Details function
    _verifyAllCarDetails(cars.items, tester);

    // TODO 10: Select a Car
    carsListBloc.selectItem(1);

    // TODO 11: Verify that Car is highlighted in blue
    WidgetPredicate widgetSelectedPredicate = (Widget widget) =>
        widget is Card && widget.color == Colors.blue.shade200;

    WidgetPredicate widgetUnselectedPredicate =
        (Widget widget) => widget is Card && widget.color == Colors.white;

    //expects that only one car is selected and the others aren't
    expect(find.byWidgetPredicate(widgetSelectedPredicate), findsOneWidget);
    expect(find.byWidgetPredicate(widgetUnselectedPredicate), findsNWidgets(5));
  });

  testWidgets('Proper error message is shown when an error occurred',
      (WidgetTester tester) async {
    // TODO 12: Inject and Load Error Mock Car Data
    carsListBloc.injectDataProviderForTest(MockCarDataProviderError());

    // TODO 13: Load and render Widget
    await tester.pumpWidget(ListPageWrapper());
    await tester.pump(Duration.zero);

    // TODO 14: Verify that Error Message is shown
    final errorFinder =
        find.text(ERROR_MESSAGE.replaceFirst(WILD_STRING, MOCK_ERROR_MESSAGE));
    expect(errorFinder, findsOneWidget);
  });

  testWidgets(
      'After encountering an error, and stream is updated, Widget is also updated.',
      (WidgetTester tester) async {
    // TODO 15: Inject and Load Error Mock Car Data
    carsListBloc.injectDataProviderForTest(MockCarDataProviderError());
    // TODO 16: Load and render Widget
    await tester.pumpWidget(ListPageWrapper());
    await tester.pump(Duration.zero);

    // TODO 17: Verify that Error Message and Retry Button is shown
    final errorFinder =
        find.text(ERROR_MESSAGE.replaceFirst(WILD_STRING, MOCK_ERROR_MESSAGE));
    final retryButtonFinder = find.text(RETRY_BUTTON);

    expect(errorFinder, findsOneWidget);
    expect(retryButtonFinder, findsOneWidget);

    // TODO 18: Inject and Load Mock Car Data
    carsListBloc.injectDataProviderForTest(MockCarDataProvider());
    await tester.tap(retryButtonFinder);

    // TODO 19: Reload Widget
    await tester.pump(Duration.zero);

    // TODO 20: Load and Verify Car Data
        CarsList cars = await MockCarDataProvider().loadCars();
        _verifyAllCarDetails(cars.items, tester);
  });
}

// TODO 8: Create a function to verify list's existence
void _verifyAllCarDetails(List<Car> carsList, WidgetTester tester) async {
  for (var car in carsList) {
    final carTitleFinder = find.text(car.title);
    final carPricePerDayFinder = find.text(PRICE_PER_DAY_TEXT.replaceFirst(
        WILD_STRING, car.pricePerDay.toStringAsFixed(2)));
    await tester.ensureVisible(carTitleFinder);
    expect(carTitleFinder, findsOneWidget);
    await tester.ensureVisible(carPricePerDayFinder);
    expect(carPricePerDayFinder, findsOneWidget);
  }
}

class ListPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListPage(),
    );
  }
}
