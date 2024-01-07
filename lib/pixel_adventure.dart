import 'dart:async';
import 'dart:io' show Platform;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  JumpButton jumpButton = JumpButton();
  bool showControls = Platform.isAndroid || Platform.isIOS;
  bool isJoystickMoving = true;
  bool playSounds = true;
  double soundVolume = 1.0;
  List<String> levelNames = ['Level-01', 'Level-01'];
  int currentLevelIndex = 0;

  List<GamepadController> _gamepads = [];

  @override
  FutureOr<void> onLoad() async {
    //Load all images into caché
    await images.loadAllImages();

    if (showControls) {
      addJoystick();
    } else {
      addGamepad();
    }
    _loadLevel();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJooystick();
    }
    super.update(dt);
  }

  void addGamepad() async {
    _gamepads = await Gamepads.list();

    for (var element in _gamepads) {
      print(element.id);
      print(element.name);
    }

    Gamepads.events.listen((GamepadEvent event) {
      if (event.key.contains("xAxis")) {
        player.horizontalMovement = event.value;
      } else if (event.key.contains("yAxis")) {
        player.hasJumped = (event.value > 0);
      } else if (event.key.contains(".circle")) {
        player.hasJumped = (event.value > 0);
      }
    });
  }

  void addJoystick() {
    add(jumpButton);
    joystick = JoystickComponent(
      priority: 10,
      background: CircleComponent(
        radius: 32,
        paint: Paint()..color = const Color(0xFF000000),
      ),
      knob: CircleComponent(
        radius: 24,
        paint: Paint()..color = const Color(0xFFFFFFFF),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void updateJooystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        isJoystickMoving = true;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        isJoystickMoving = true;
        break;
      default:
        if (isJoystickMoving) {
          isJoystickMoving = false;
          player.horizontalMovement = 0;
        }

        break;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);

    if (currentLevelIndex >= levelNames.length - 1) currentLevelIndex = -1;

    currentLevelIndex++;
    _loadLevel();
  }

  void _loadLevel() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Level worldLevel = Level(
        levelName: levelNames[currentLevelIndex],
        player: player,
      );

      cam = CameraComponent.withFixedResolution(
        world: worldLevel,
        height: 360,
        width: 640,
        //hudComponents: (showControls) ? [joystick] : [],
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      //addAll([cam, worldLevel]);
      add(cam);
      add(worldLevel);
      //worldLevel.priority = 0;
      cam.priority = 0;
    });
  }
}
