import 'package:data_connection_checker_tv/data_connection_checker.dart';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:pokemon_clean_architecture/core/constants/constants.dart';
import 'package:pokemon_clean_architecture/features/pokemon/business/entities/pokemon_entity.dart';
import 'package:pokemon_clean_architecture/features/pokemon_image/data/repositories/pokemon_Image_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/params/params.dart';
import '../../business/entities/pokemon_image_entity.dart';
import '../../business/usecases/get_pokemon_image.dart';
import '../../data/datasources/pokemon_image_local_data_source.dart';
import '../../data/datasources/pokemon_image_remote_data_source.dart';

class PokemonImageProvider extends ChangeNotifier {
  PokemonImageEntity? pokemonImage;
  Failure? failure;

  PokemonImageProvider({
    this.pokemonImage,
    this.failure,
  });

  void eitherFailureOrPokemonImage({required PokemonEntity pokemonEntity}) async {
    PokemonImageRepositoryImpl repository = PokemonImageRepositoryImpl(
      pokemonImageRemoteDataSource: PokemonImageRemoteDataSourceImpl(
        dio: Dio(),
      ),
      pokemonImageLocalDataSource: PokemonImageLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    String imageUrl = isShiny
        ? pokemonEntity.sprites.other.officialArtwork.frontShiny
        : pokemonEntity.sprites.other.officialArtwork.frontDefault;

    final failureOrPokemonImage =
        await GetPokemonImage(pokemonImageRepository: repository).call(
      pokemonImageParams:
          PokemonImageParams(imageUrl: imageUrl, name: pokemonEntity.name),
    );

    failureOrPokemonImage.fold(
      (Failure newFailure) {
        pokemonImage = null;
        failure = newFailure;
        notifyListeners();
      },
      (PokemonImageEntity newPokemonImage) {
        pokemonImage = newPokemonImage;
        failure = null;
        notifyListeners();
      },
    );
  }
}
