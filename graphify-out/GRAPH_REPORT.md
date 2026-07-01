# Graph Report - polislot_mobile_catz  (2026-07-02)

## Corpus Check
- 111 files · ~72,950 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1598 nodes · 2098 edges · 118 communities (90 shown, 28 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `05e3da9d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 81|Community 81]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 87|Community 87]]
- [[_COMMUNITY_Community 88|Community 88]]
- [[_COMMUNITY_Community 89|Community 89]]
- [[_COMMUNITY_Community 90|Community 90]]
- [[_COMMUNITY_Community 91|Community 91]]
- [[_COMMUNITY_Community 93|Community 93]]
- [[_COMMUNITY_Community 95|Community 95]]
- [[_COMMUNITY_Community 96|Community 96]]
- [[_COMMUNITY_Community 97|Community 97]]
- [[_COMMUNITY_Community 98|Community 98]]
- [[_COMMUNITY_Community 99|Community 99]]
- [[_COMMUNITY_Community 100|Community 100]]
- [[_COMMUNITY_Community 101|Community 101]]
- [[_COMMUNITY_Community 105|Community 105]]
- [[_COMMUNITY_Community 107|Community 107]]
- [[_COMMUNITY_Community 112|Community 112]]
- [[_COMMUNITY_Community 118|Community 118]]
- [[_COMMUNITY_Community 128|Community 128]]
- [[_COMMUNITY_Community 140|Community 140]]
- [[_COMMUNITY_Community 141|Community 141]]
- [[_COMMUNITY_Community 143|Community 143]]

## God Nodes (most connected - your core abstractions)
1. `Create()` - 10 edges
2. `MessageHandler()` - 10 edges
3. `_HomeScreenState` - 9 edges
4. `_RewardScreenState` - 9 edges
5. `WndProc()` - 9 edges
6. `list` - 8 edges
7. `_MissionScreenState` - 8 edges
8. `PoliSlot Mobile App` - 8 edges
9. `_MyApplication` - 7 edges
10. `HWND` - 7 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `_HomeScreenState` --references--> `bottomNavIndexProvider`  [EXTRACTED]
  lib/features/home/presentation/home_screen.dart → lib/features/home/presentation/main_screen.dart
- `_buildLeaderboardCard` --references--> `bottomNavIndexProvider`  [EXTRACTED]
  lib/features/home/presentation/home_screen.dart → lib/features/home/presentation/main_screen.dart
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  linux/runner/my_application.cc → linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  linux/runner/main.cc → linux/runner/my_application.cc

## Import Cycles
- None detected.

## Communities (118 total, 28 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.06
Nodes (34): dart:ui, ../../info_board/data/info_board_model.dart, ../../info_board/presentation/info_board_controller.dart, main_screen.dart, ../../mission/data/mission_model.dart, package:intl/intl.dart, package:smooth_page_indicator/smooth_page_indicator.dart, ../../park/data/park_model.dart (+26 more)

### Community 1 - "Community 1"
Cohesion: 0.07
Nodes (26): bool get, avatar, completedAt, description, fromJson, id, isCompleted, isCurrentUser (+18 more)

### Community 2 - "Community 2"
Cohesion: 0.03
Nodes (79): AsyncValue, BuildContext, _buildDetailSection, Container, Divider, GoogleMap, InkWell, launchUrl (+71 more)

### Community 3 - "Community 3"
Cohesion: 0.10
Nodes (20): Scaffold, SizedBox, Stack, Text, ../../../core/widgets/custom_button.dart, ../../../core/routes/app_routes.dart, ../../../core/theme/app_theme.dart, ../../../core/widgets/custom_button.dart (+12 more)

### Community 4 - "Community 4"
Cohesion: 0.12
Nodes (14): answer, FaqModel, fromJson, id, question, toJson, FeedbackCategory, fromJson (+6 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (35): AppLinks, Icon, initializeDateFormatting, MaterialApp, SizedBox, Text, core/security/key_manager.dart, core/utils/navigator_key.dart (+27 more)

### Community 6 - "Community 6"
Cohesion: 0.04
Nodes (43): AppConnectivityWrapper, MaterialPageRoute, PageRouteBuilder, SlideTransition, ../enums/otp_type.dart, ../../features/auth/presentation/forgot_password_screen.dart, ../../features/auth/presentation/login_regis_screen.dart, ../../features/auth/presentation/login_screen.dart (+35 more)

### Community 7 - "Community 7"
Cohesion: 0.20
Nodes (15): Column, Container, ListView, Scaffold, SizedBox, faq_controller.dart, ../../features/faq/presentation/faq_screen.dart, ../../../core/providers/connection_status_provider.dart (+7 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (44): DartProject, RegisterPlugins(), PluginRegistry, Point, RECT, MessageHandler(), OnCreate(), Create() (+36 more)

### Community 9 - "Community 9"
Cohesion: 0.10
Nodes (19): currentPage, date, fromJson, HistoryItem, HistoryResponse, id, isNegative, lastPage (+11 more)

### Community 10 - "Community 10"
Cohesion: 0.11
Nodes (17): list, code, createdAt, currentPoints, fromJson, id, image, name (+9 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (40): Container, Padding, Scaffold, SizedBox, Text, ../../../auth/presentation/auth_controller.dart, ../../../../core/utils/snackbar_utils.dart, ../../../../core/utils/validator_utils.dart (+32 more)

### Community 12 - "Community 12"
Cohesion: 0.13
Nodes (14): avatar, createdAt, email, emailVerifiedAt, fromJson, id, name, role (+6 more)

### Community 13 - "Community 13"
Cohesion: 0.10
Nodes (21): Container, ListTile, Scaffold, SizedBox, Text, feedback_controller.dart, feedbackFormControllerProvider, package:dropdown_search/dropdown_search.dart (+13 more)

### Community 14 - "Community 14"
Cohesion: 0.12
Nodes (15): avatar, Comment, CommentUser, content, date, fromJson, id, image (+7 more)

### Community 15 - "Community 15"
Cohesion: 0.05
Nodes (39): SizedBox, Center, CurvedAnimation, FadeTransition, Function, GestureDetector, Icon, SingleChildScrollView (+31 more)

### Community 16 - "Community 16"
Cohesion: 0.10
Nodes (22): FlPluginRegistry, fl_register_plugins(), FlView, GApplication, gboolean, gchar, GObject, GtkApplication (+14 more)

### Community 17 - "Community 17"
Cohesion: 0.13
Nodes (14): Function, TextFormField, IconData?, package:flutter/material.dart, TextEditingController, TextInputType, build, controller (+6 more)

### Community 18 - "Community 18"
Cohesion: 0.18
Nodes (10): ../data/faq_model.dart, ../data/faq_repository.dart, package:riverpod_annotation/riverpod_annotation.dart, build, getOfflineFaqs, getServerErrorFaqs, _offlineFaqs, refresh (+2 more)

### Community 19 - "Community 19"
Cohesion: 0.09
Nodes (22): Padding, Scaffold, SizedBox, Text, ../../auth/presentation/auth_controller.dart, ../../../core/routes/app_routes.dart, ../../../core/theme/app_theme.dart, ../../../core/widgets/custom_button.dart (+14 more)

### Community 20 - "Community 20"
Cohesion: 0.07
Nodes (26): Scaffold, SizedBox, Text, ../../../core/widgets/custom_textfield.dart, auth_controller.dart, ../../../core/enums/otp_type.dart, ../../../core/routes/app_routes.dart, ../../../core/theme/app_theme.dart (+18 more)

### Community 21 - "Community 21"
Cohesion: 0.07
Nodes (27): ClampingScrollPhysics, Scaffold, SingleChildScrollView, SizedBox, Text, auth_controller.dart, ../../../core/routes/app_routes.dart, ../../../core/theme/app_theme.dart (+19 more)

### Community 22 - "Community 22"
Cohesion: 0.06
Nodes (34): LatLng, amenities, areaCode, areaId, areaName, canValidate, code, commentCount (+26 more)

### Community 23 - "Community 23"
Cohesion: 0.13
Nodes (14): Exception, comment_model.dart, build, CommentRepository, deleteComment, _dio, editComment, getComments (+6 more)

### Community 24 - "Community 24"
Cohesion: 0.07
Nodes (29): Alignment, alignment, _animController, _buildLeaderboard, _buildMissionLoading, _buildMissionsList, _buildOfflinePlaceholder, _buildPodium (+21 more)

### Community 25 - "Community 25"
Cohesion: 0.17
Nodes (11): auth_controller.dart, ../../../core/enums/otp_type.dart, core/theme/app_theme.dart, FormState, build, createState, _emailController, _formKey (+3 more)

### Community 26 - "Community 26"
Cohesion: 0.17
Nodes (11): ../data/mission_model.dart, ../data/mission_repository.dart, ../data/mission_model.dart, missionControllerProvider, missionTabStateProvider, package:riverpod_annotation/riverpod_annotation.dart, build, MissionController (+3 more)

### Community 27 - "Community 27"
Cohesion: 0.08
Nodes (25): comment_controller.dart, File?, ImagePicker, package:image_picker/image_picker.dart, _buildCommentCard, _buildCommentLoading, _buildInputSection, _buildOfflineCard (+17 more)

### Community 28 - "Community 28"
Cohesion: 0.07
Nodes (27): Exception, UnimplementedError, AuthRepository, build, checkConnectivity, _dio, fetchUserProfile, forgotPasswordOtpResend (+19 more)

### Community 29 - "Community 29"
Cohesion: 0.12
Nodes (16): Animation, AnimatedBuilder, Opacity, package:flutter/material.dart, AnimatedParkingLogo, _AnimatedParkingLogoState, build, createState (+8 more)

### Community 30 - "Community 30"
Cohesion: 0.15
Nodes (12): ../../auth/data/user_model.dart, Exception, build, _dio, ProfileRepository, updateProfile, ../../../core/network/dio_client.dart, dart:convert (+4 more)

### Community 31 - "Community 31"
Cohesion: 0.06
Nodes (41): ../data/reward_model.dart, ../data/reward_repository.dart, ../../history/data/history_model.dart, ../../history/presentation/history_controller.dart, ../data/reward_model.dart, ../../history/presentation/history_controller.dart, package:riverpod_annotation/riverpod_annotation.dart, historyControllerProvider (+33 more)

### Community 32 - "Community 32"
Cohesion: 0.06
Nodes (33): Color, Container, LayoutBuilder, Scaffold, SizedBox, Text, ../../auth/presentation/auth_controller.dart, ../../../core/routes/app_routes.dart (+25 more)

### Community 33 - "Community 33"
Cohesion: 0.05
Nodes (30): Any, app_links, Cocoa, connectivity_plus, file_selector_macos, Flutter, RegisterGeneratedPlugins(), FlutterAppDelegate (+22 more)

### Community 34 - "Community 34"
Cohesion: 0.14
Nodes (14): AnimationController, FadeTransition, package:flutter/material.dart, AnimatedLogo, _AnimatedLogoState, build, _controller, createState (+6 more)

### Community 35 - "Community 35"
Cohesion: 0.09
Nodes (21): mqttServiceProvider, MqttServerClient?, package:mqtt_client/mqtt_client.dart, package:mqtt_client/mqtt_server_client.dart, build, _client, _connect, _disposed (+13 more)

### Community 36 - "Community 36"
Cohesion: 0.10
Nodes (19): code:text (lib/), code:bash (git clone <url-repository>), code:env (API_URL=http://<ip-backend-anda>/api), code:bash (dart run build_runner build --delete-conflicting-outputs), code:bash (# Menjalankan untuk mode debug), 1. Persiapan Awal, 2. Kloning Repository, 3. Mengunduh Dependencies (+11 more)

### Community 37 - "Community 37"
Cohesion: 0.12
Nodes (16): Scaffold, SizedBox, Text, OtpType, package:pin_code_fields/pin_code_fields.dart, build, createState, dispose (+8 more)

### Community 38 - "Community 38"
Cohesion: 0.14
Nodes (13): dart:convert, dart:math, key_manager.dart, dart:convert, package:dio/dio.dart, package:encrypt/encrypt.dart, package:flutter/foundation.dart, _decryptResponse (+5 more)

### Community 39 - "Community 39"
Cohesion: 0.06
Nodes (39): Exception, HomeScreen, MissionScreen, PopScope, ProfileScreen, RewardScreen, showDialog, home_screen.dart (+31 more)

### Community 40 - "Community 40"
Cohesion: 0.12
Nodes (16): Scaffold, ../../home/presentation/main_screen.dart, ../../auth/presentation/auth_controller.dart, ../../../core/routes/app_routes.dart, ../../mission/presentation/mission_controller.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, ../../reward/presentation/reward_controller.dart (+8 more)

### Community 41 - "Community 41"
Cohesion: 0.15
Nodes (19): ConsumerState, ConsumerStatefulWidget, ForgotPasswordScreen, _ForgotPasswordScreenState, LoginScreen, _LoginScreenState, _MqttStatusIndicator, _MqttStatusIndicatorState (+11 more)

### Community 42 - "Community 42"
Cohesion: 0.18
Nodes (10): Exception, build, _dio, getHistory, HistoryRepository, Dio, history_model.dart, ../../../core/network/dio_client.dart (+2 more)

### Community 43 - "Community 43"
Cohesion: 0.20
Nodes (9): ../../../core/network/dio_client.dart, build, _dio, FaqRepository, getFaqs, faq_model.dart, ../../../core/network/dio_client.dart, package:dio/dio.dart (+1 more)

### Community 44 - "Community 44"
Cohesion: 0.18
Nodes (10): Exception, build, _dio, FeedbackRepository, getCategories, sendFeedback, feedback_category_model.dart, ../../../core/network/dio_client.dart (+2 more)

### Community 45 - "Community 45"
Cohesion: 0.20
Nodes (9): Exception, build, _dio, getInfoBoards, InfoBoardRepository, info_board_model.dart, ../../../core/network/dio_client.dart, package:dio/dio.dart (+1 more)

### Community 46 - "Community 46"
Cohesion: 0.20
Nodes (9): Exception, build, _dio, getMissionData, MissionRepository, ../../../core/network/dio_client.dart, package:dio/dio.dart, package:riverpod_annotation/riverpod_annotation.dart (+1 more)

### Community 47 - "Community 47"
Cohesion: 0.17
Nodes (11): Exception, build, _dio, getParkAreas, getParkVisualization, ParkRepository, sendValidation, ../../../core/network/dio_client.dart (+3 more)

### Community 48 - "Community 48"
Cohesion: 0.17
Nodes (11): Exception, build, _dio, getHistory, getRewards, redeemReward, RewardRepository, ../../../core/network/dio_client.dart (+3 more)

### Community 49 - "Community 49"
Cohesion: 0.11
Nodes (22): set, core/services/mqtt_service.dart, ../data/park_model.dart, ../data/park_repository.dart, parkAreaListControllerProvider, parkVisualizationControllerProvider, validationActionControllerProvider, parkRepositoryInstanceProvider (+14 more)

### Community 50 - "Community 50"
Cohesion: 0.13
Nodes (17): ../../../core/providers/connection_status_provider.dart, dart:async, ../../features/profile/presentation/sections/profile_reward_section.dart, mission_controller.dart, ../../mission/presentation/mission_screen.dart, rewardHistoryControllerProvider, package:font_awesome_flutter/font_awesome_flutter.dart, ../../../reward/data/reward_model.dart (+9 more)

### Community 51 - "Community 51"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 52 - "Community 52"
Cohesion: 0.07
Nodes (40): _, @Riverpod, AuthRepositoryInstance, CommentRepositoryInstance, FaqRepositoryInstance, FeedbackRepositoryInstance, HistoryRepositoryInstance, InfoBoardRepositoryInstance (+32 more)

### Community 53 - "Community 53"
Cohesion: 0.14
Nodes (13): core/routes/app_routes.dart, ../../../../core/utils/validator_utils.dart, build, _confirmPasswordController, createState, _deepBlue, dispose, email (+5 more)

### Community 54 - "Community 54"
Cohesion: 0.17
Nodes (12): @JsonSerializable, PaginationMeta, LeaderboardItem, MissionItem, MissionScreenData, UserStats, ParkAreaItem, ParkSubareaVisual (+4 more)

### Community 55 - "Community 55"
Cohesion: 0.18
Nodes (10): ../data/comment_model.dart, ../data/comment_repository.dart, dart:io, ../data/comment_model.dart, package:riverpod_annotation/riverpod_annotation.dart, build, deleteComment, editComment (+2 more)

### Community 56 - "Community 56"
Cohesion: 0.18
Nodes (10): ../data/feedback_category_model.dart, ../data/feedback_repository.dart, feedbackCategoriesControllerProvider, ../data/feedback_category_model.dart, feedbackFormControllerProvider, package:riverpod_annotation/riverpod_annotation.dart, build, FeedbackCategoriesController (+2 more)

### Community 57 - "Community 57"
Cohesion: 0.67
Nodes (4): _MarqueeText, _MarqueeTextState, _MarqueeTextState, State

### Community 58 - "Community 58"
Cohesion: 0.23
Nodes (9): _In_, _In_opt_, wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), vector, string (+1 more)

### Community 59 - "Community 59"
Cohesion: 0.20
Nodes (9): content, createdAt, fromJson, id, InfoBoard, title, toJson, DateTime (+1 more)

### Community 60 - "Community 60"
Cohesion: 0.33
Nodes (6): build, build, build, AppRoutes.forgotPassword, AppRoutes.login, AppRoutes.register

### Community 61 - "Community 61"
Cohesion: 0.20
Nodes (9): setOffline, connectionStatusProvider, package:riverpod_annotation/riverpod_annotation.dart, build, ConnectionStateType, ConnectionStatus, setNoInternet, setOnline (+1 more)

### Community 62 - "Community 62"
Cohesion: 0.14
Nodes (20): Stack, ConsumerWidget, ../../core/wrapper/connectivity_wrapper.dart, build, connectionStatusProvider, infoBoardControllerProvider, missionControllerProvider, missionTabStateProvider (+12 more)

### Community 63 - "Community 63"
Cohesion: 0.06
Nodes (35): auth_interceptor.dart, AlertDialog, ../data/user_model.dart, package:connectivity_plus/connectivity_plus.dart, package:dio/dio.dart, package:flutter_dotenv/flutter_dotenv.dart, package:flutter/material.dart, package:riverpod_annotation/riverpod_annotation.dart (+27 more)

### Community 64 - "Community 64"
Cohesion: 0.22
Nodes (8): ../../../../core/utils/snackbar_utils.dart, ../../core/utils/snackbar_utils.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, ../providers/connection_status_provider.dart, ../providers/connection_status_provider.dart, Widget, child

### Community 65 - "Community 65"
Cohesion: 0.22
Nodes (8): ../../auth/presentation/auth_controller.dart, dart:io, ../data/profile_repository.dart, ../../auth/presentation/auth_controller.dart, dart:io, package:riverpod_annotation/riverpod_annotation.dart, build, updateProfile

### Community 66 - "Community 66"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 67 - "Community 67"
Cohesion: 0.22
Nodes (8): Interceptor, package:dio/dio.dart, package:shared_preferences/shared_preferences.dart, AuthInterceptor, onRequest, package:dio/dio.dart, package:shared_preferences/shared_preferences.dart, EncryptionInterceptor

### Community 68 - "Community 68"
Cohesion: 0.18
Nodes (10): ../data/history_model.dart, ../data/history_repository.dart, historyControllerProvider, package:riverpod_annotation/riverpod_annotation.dart, build, _currentPage, HistoryController, _isLoadingMore (+2 more)

### Community 69 - "Community 69"
Cohesion: 0.29
Nodes (6): ../data/info_board_model.dart, ../data/info_board_repository.dart, infoBoardControllerProvider, package:riverpod_annotation/riverpod_annotation.dart, build, InfoBoardController

### Community 70 - "Community 70"
Cohesion: 0.40
Nodes (4): package:riverpod_annotation/riverpod_annotation.dart, package:riverpod_annotation/riverpod_annotation.dart, build, setSection

### Community 71 - "Community 71"
Cohesion: 0.15
Nodes (12): ThemeData, package:flutter/material.dart, static const Color, static const LinearGradient, AppTheme, backgroundGradient, error, primaryColor (+4 more)

### Community 72 - "Community 72"
Cohesion: 0.15
Nodes (11): map, GlobalKey, package:flutter/material.dart, package:flutter/material.dart, NavigatorState, package:flutter/material.dart, isAppInitialized, navigatorKey (+3 more)

### Community 86 - "Community 86"
Cohesion: 0.40
Nodes (4): version, images, info, author

### Community 95 - "Community 95"
Cohesion: 0.25
Nodes (8): _MarqueeText, LoginRegisScreen, _LoginRegisScreenState, _MarqueeText, PrivacyPolicyScreen, _PrivacyPolicyScreenState, StatefulWidget, TickerProviderStateMixin

### Community 96 - "Community 96"
Cohesion: 0.50
Nodes (5): commentActionControllerProvider, commentListControllerProvider, build, CommentScreen, _CommentScreenState

### Community 97 - "Community 97"
Cohesion: 0.40
Nodes (5): build, AppRoutes.faq, AppRoutes.feedback, AppRoutes.profileEdit, AppRoutes.profileReward

### Community 98 - "Community 98"
Cohesion: 0.22
Nodes (8): ProviderScope, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart, package:polislot_mobile_catz/main.dart, package:flutter_dotenv/flutter_dotenv.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, main

## Knowledge Gaps
- **981 isolated node(s):** `SBFrame`, `SBDebugger`, `flutter_export_environment.sh script`, `UIApplication`, `Any` (+976 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **28 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `list` connect `Community 10` to `Community 0`, `Community 1`, `Community 2`, `Community 39`, `Community 9`, `Community 15`, `Community 22`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Why does `DioClientService` connect `Community 52` to `Community 62`, `Community 63`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `SBFrame`, `SBDebugger`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` to the rest of the system?**
  _982 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05714285714285714 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.07407407407407407 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.025 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._