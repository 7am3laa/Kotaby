// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:quran/quran.dart';
// import 'package:quran/surah_data.dart';
// import 'package:string_validator/string_validator.dart';

// class AllSurahState {
//   final bool isSearch;
//   final bool isLoading;
//   final List filteredData;
//   final dynamic ayatFiltered;
//   final List pageNumbers;

//   AllSurahState({
//     required this.isSearch,
//     required this.isLoading,
//     required this.filteredData,
//     required this.ayatFiltered,
//     required this.pageNumbers,
//   });

//   AllSurahState copyWith({
//     bool? isSearch,
//     bool? isLoading,
//     List? filteredData,
//     dynamic ayatFiltered,
//     List? pageNumbers,
//   }) {
//     return AllSurahState(
//       isSearch: isSearch ?? this.isSearch,
//       isLoading: isLoading ?? this.isLoading,
//       filteredData: filteredData ?? this.filteredData,
//       ayatFiltered: ayatFiltered ?? this.ayatFiltered,
//       pageNumbers: pageNumbers ?? this.pageNumbers,
//     );
//   }
// }

// class AllSurahCubit extends Cubit<AllSurahState> {
//   AllSurahCubit()
//       : super(AllSurahState(
//           isSearch: false,
//           isLoading: true,
//           filteredData: [],
//           ayatFiltered: null,
//           pageNumbers: [],
//         ));

//   void addFilteredData() {
//     emit(state.copyWith(filteredData: surah, isLoading: false));
//   }

//   void toggleSearch() {
//     emit(state.copyWith(isSearch: !state.isSearch));
//   }

//   void searchLogic(String value) {
//     if (value.isEmpty) {
//       emit(state.copyWith(
//         filteredData: surah,
//         pageNumbers: [],
//         ayatFiltered: null,
//       ));
//       return;
//     }

//     if (isInt(value) && toInt(value) > 0 && toInt(value) < 605) {
//       emit(state.copyWith(pageNumbers: [toInt(value)]));
//     }

//     if (value.length > 3 || value.contains(" ")) {
//       final ayatFiltered = searchWords(value);
//       final filteredData = surah.where((surah) {
//         final suraName = surah['name'].toLowerCase();
//         final suraNameTranslated = getSurahNameArabic(surah["id"]);
//         return suraName.contains(value.toLowerCase()) ||
//             suraNameTranslated.contains(value.toLowerCase());
//       }).toList();

//       emit(state.copyWith(
//         filteredData: filteredData,
//         ayatFiltered: ayatFiltered,
//       ));
//     }
//   }

//   void clearSearch() {
//     emit(state.copyWith(
//       ayatFiltered: null,
//       pageNumbers: [],
//       filteredData: surah,
//     ));
//   }
// }
