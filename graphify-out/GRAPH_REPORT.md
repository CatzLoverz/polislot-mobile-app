# Graph Report - polislot_mobile_catz  (2026-05-15)

## Corpus Check
- 133 files · ~73,343 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 917 nodes · 1264 edges · 98 communities (91 shown, 7 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2fe596ae`
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
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 98|Community 98]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 40 edges
2. `package:flutter_riverpod/flutter_riverpod.dart` - 29 edges
3. `package:riverpod_annotation/riverpod_annotation.dart` - 26 edges
4. `../../../core/providers/connection_status_provider.dart` - 20 edges
5. `package:dio/dio.dart` - 16 edges
6. `../../../../core/utils/snackbar_utils.dart` - 10 edges
7. `../../auth/presentation/auth_controller.dart` - 10 edges
8. `../../../core/routes/app_routes.dart` - 10 edges
9. `package:json_annotation/json_annotation.dart` - 9 edges
10. `package:flutter_dotenv/flutter_dotenv.dart` - 8 edges

## Surprising Connections (you probably didn't know these)
- `../../../core/providers/connection_status_provider.dart` --defines--> `ConnectionStatus`  [EXTRACTED]
  features/reward/presentation/reward_screen.dart → core/providers/connection_status_provider.dart
- `../../../core/providers/connection_status_provider.dart` --defines--> `build`  [EXTRACTED]
  features/reward/presentation/reward_screen.dart → core/providers/connection_status_provider.dart
- `../../../core/providers/connection_status_provider.dart` --defines--> `setNoInternet`  [EXTRACTED]
  features/reward/presentation/reward_screen.dart → core/providers/connection_status_provider.dart
- `../../../core/providers/connection_status_provider.dart` --defines--> `setServerUnreachable`  [EXTRACTED]
  features/reward/presentation/reward_screen.dart → core/providers/connection_status_provider.dart
- `../../../core/providers/connection_status_provider.dart` --defines--> `setOnline`  [EXTRACTED]
  features/reward/presentation/reward_screen.dart → core/providers/connection_status_provider.dart

## Communities (98 total, 7 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.08
Nodes (45): AlertDialog, Align, build, _buildGreetingCard, _buildInfoBoardCard, _buildInfoBoardLoading, _buildInfoBoardPlaceholder, _buildLeaderboardCard (+37 more)

### Community 1 - "Community 1"
Cohesion: 0.08
Nodes (43): build, RewardController, RewardHistoryController, RewardTabState, setHistoryTab, setRewardTab, AlertDialog, build (+35 more)

### Community 2 - "Community 2"
Cohesion: 0.08
Nodes (41): build, MissionController, MissionTabState, setLeaderboard, setMission, Align, _animatedTabs, build (+33 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (38): ParkAreaListController, ParkVisualizationController, SelectedSubarea, set, ValidationActionController, build, _buildDetailSection, Container (+30 more)

### Community 4 - "Community 4"
Cohesion: 0.06
Nodes (24): User, FaqModel, FeedbackCategory, HistoryItem, HistoryResponse, PaginationMeta, InfoBoard, LeaderboardItem (+16 more)

### Community 5 - "Community 5"
Cohesion: 0.09
Nodes (21): build, didChangeAppLifecycleState, dispose, Icon, initializeDateFormatting, initState, main, MaterialApp (+13 more)

### Community 6 - "Community 6"
Cohesion: 0.08
Nodes (31): AppConnectivityWrapper, AppRoutes, MaterialPageRoute, _materialRoute, PageRouteBuilder, _slideRoute, SlideTransition, build (+23 more)

### Community 7 - "Community 7"
Cohesion: 0.28
Nodes (11): auth_interceptor.dart, AlertDialog, build, DioClientService, DioErrorHandler, parse, package:flutter_dotenv/flutter_dotenv.dart, package:shared_preferences/shared_preferences.dart (+3 more)

### Community 8 - "Community 8"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 9 - "Community 9"
Cohesion: 0.18
Nodes (19): build, _buildHistoryCard, _buildHistoryLoading, _buildOfflinePlaceholder, Center, Container, dispose, initState (+11 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (33): _decryptResponse, EncryptionInterceptor, _generateRandomString, onError, onRequest, onResponse, Exception, KeyManager (+25 more)

### Community 11 - "Community 11"
Cohesion: 0.06
Nodes (46): ../../auth/presentation/auth_controller.dart, CommentActionController, CommentListController, build, _buildCommentCard, _buildCommentLoading, _buildInputSection, _buildOfflineCard (+38 more)

### Community 12 - "Community 12"
Cohesion: 0.1
Nodes (19): 1. Persiapan Awal, 2. Kloning Repository, 3. Mengunduh Dependencies, 4. Konfigurasi Environment & Asset, 5. Code Generation (Riverpod & JSON Serializable), 6. Jalankan Aplikasi, code:text (lib/), code:bash (git clone <url-repository>) (+11 more)

### Community 13 - "Community 13"
Cohesion: 0.11
Nodes (16): FeedbackCategoriesController, FeedbackFormController, build, Container, dispose, FeedbackScreen, _FeedbackScreenState, _inputField (+8 more)

### Community 14 - "Community 14"
Cohesion: 0.13
Nodes (14): build, Color, Container, _createShimmerShader, dispose, _GradientText, initState, LayoutBuilder (+6 more)

### Community 15 - "Community 15"
Cohesion: 0.13
Nodes (14): build, Center, CurvedAnimation, dispose, FadeTransition, Function, GestureDetector, Icon (+6 more)

### Community 16 - "Community 16"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 17 - "Community 17"
Cohesion: 0.19
Nodes (9): AppTheme, ThemeData, AppSnackBars, show, AppConnectivityWrapper, build, Stack, ../../../../core/utils/snackbar_utils.dart (+1 more)

### Community 18 - "Community 18"
Cohesion: 0.12
Nodes (13): FaqController, HistoryController, InfoBoardController, build, ProfileSection, setSection, ../data/faq_model.dart, ../data/faq_repository.dart (+5 more)

### Community 19 - "Community 19"
Cohesion: 0.17
Nodes (11): build, _buildSection, dispose, initState, Padding, PrivacyPolicyScreen, _PrivacyPolicyScreenState, Scaffold (+3 more)

### Community 20 - "Community 20"
Cohesion: 0.18
Nodes (10): build, dispose, initState, LoginRegisScreen, _LoginRegisScreenState, Scaffold, SizedBox, Stack (+2 more)

### Community 21 - "Community 21"
Cohesion: 0.18
Nodes (10): build, ClampingScrollPhysics, dispose, initState, LoginScreen, _LoginScreenState, Scaffold, SingleChildScrollView (+2 more)

### Community 22 - "Community 22"
Cohesion: 0.2
Nodes (9): build, dispose, initState, ResetPasswordScreen, _ResetPasswordScreenState, Scaffold, SizedBox, Text (+1 more)

### Community 23 - "Community 23"
Cohesion: 0.33
Nodes (5): build, CommentRepository, CommentRepositoryInstance, Exception, comment_model.dart

### Community 24 - "Community 24"
Cohesion: 0.18
Nodes (10): build, dispose, initState, RegisterScreen, _RegisterScreenState, Scaffold, SizedBox, Text (+2 more)

### Community 25 - "Community 25"
Cohesion: 0.2
Nodes (9): build, dispose, initState, Scaffold, SizedBox, Text, VerifyOtpScreen, _VerifyOtpScreenState (+1 more)

### Community 26 - "Community 26"
Cohesion: 0.2
Nodes (9): build, ProfileScreen, _ProfileScreenState, Scaffold, _showLogoutDialog, ../../../core/routes/app_routes.dart, ../../home/presentation/main_screen.dart, ../../mission/presentation/mission_controller.dart (+1 more)

### Community 27 - "Community 27"
Cohesion: 0.22
Nodes (8): auth_controller.dart, build, ForgotPasswordScreen, _ForgotPasswordScreenState, Scaffold, SizedBox, Text, ../../../core/enums/otp_type.dart

### Community 28 - "Community 28"
Cohesion: 0.25
Nodes (7): AuthRepository, AuthRepositoryInstance, build, Exception, _handleAuthResponse, UnimplementedError, user_model.dart

### Community 29 - "Community 29"
Cohesion: 0.25
Nodes (7): AnimatedBuilder, AnimatedParkingLogo, _AnimatedParkingLogoState, build, dispose, initState, Opacity

### Community 30 - "Community 30"
Cohesion: 0.29
Nodes (6): ../../auth/data/user_model.dart, build, Exception, ProfileRepository, ProfileRepositoryInstance, dart:convert

### Community 31 - "Community 31"
Cohesion: 0.33
Nodes (7): call, create, debugGetCreateSourceHash, overrideWithValue, runBuild, toString, _

### Community 32 - "Community 32"
Cohesion: 0.33
Nodes (7): call, create, debugGetCreateSourceHash, overrideWithValue, runBuild, toString, _

### Community 34 - "Community 34"
Cohesion: 0.29
Nodes (6): AnimatedLogo, _AnimatedLogoState, build, dispose, FadeTransition, initState

### Community 35 - "Community 35"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 36 - "Community 36"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 37 - "Community 37"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 38 - "Community 38"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 39 - "Community 39"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 40 - "Community 40"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 41 - "Community 41"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 42 - "Community 42"
Cohesion: 0.33
Nodes (5): build, Exception, HistoryRepository, HistoryRepositoryInstance, history_model.dart

### Community 43 - "Community 43"
Cohesion: 0.22
Nodes (7): AuthInterceptor, onRequest, build, FaqRepository, FaqRepositoryInstance, faq_model.dart, package:dio/dio.dart

### Community 44 - "Community 44"
Cohesion: 0.33
Nodes (5): build, Exception, FeedbackRepository, FeedbackRepositoryInstance, feedback_category_model.dart

### Community 45 - "Community 45"
Cohesion: 0.33
Nodes (5): build, Exception, InfoBoardRepository, InfoBoardRepositoryInstance, info_board_model.dart

### Community 46 - "Community 46"
Cohesion: 0.33
Nodes (5): build, Exception, MissionRepository, MissionRepositoryInstance, mission_model.dart

### Community 47 - "Community 47"
Cohesion: 0.33
Nodes (5): build, Exception, ParkRepository, ParkRepositoryInstance, park_model.dart

### Community 48 - "Community 48"
Cohesion: 0.33
Nodes (5): build, Exception, RewardRepository, RewardRepositoryInstance, reward_model.dart

### Community 49 - "Community 49"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 50 - "Community 50"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 51 - "Community 51"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 52 - "Community 52"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 53 - "Community 53"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 54 - "Community 54"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 55 - "Community 55"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 56 - "Community 56"
Cohesion: 0.4
Nodes (6): build, create, debugGetCreateSourceHash, overrideWithValue, runBuild, _

### Community 57 - "Community 57"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 58 - "Community 58"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 59 - "Community 59"
Cohesion: 0.43
Nodes (6): AuthController, updateUser, ../data/auth_repository.dart, ../data/user_model.dart, package:connectivity_plus/connectivity_plus.dart, package:flutter/foundation.dart

### Community 61 - "Community 61"
Cohesion: 0.39
Nodes (7): build, ConnectionStatus, setNoInternet, setOffline, setOnline, setServerUnreachable, ../../../core/providers/connection_status_provider.dart

### Community 62 - "Community 62"
Cohesion: 0.4
Nodes (4): build, CustomButton, SizedBox, ../theme/app_theme.dart

### Community 63 - "Community 63"
Cohesion: 0.4
Nodes (4): build, CustomTextField, Function, TextFormField

### Community 64 - "Community 64"
Cohesion: 0.5
Nodes (3): isValidEmail, isValidPassword, ValidatorUtils

### Community 65 - "Community 65"
Cohesion: 0.67
Nodes (4): create, debugGetCreateSourceHash, runBuild, _

### Community 67 - "Community 67"
Cohesion: 0.67
Nodes (4): create, debugGetCreateSourceHash, runBuild, _

### Community 69 - "Community 69"
Cohesion: 0.67
Nodes (4): create, debugGetCreateSourceHash, runBuild, _

### Community 70 - "Community 70"
Cohesion: 0.67
Nodes (4): create, debugGetCreateSourceHash, runBuild, _

### Community 71 - "Community 71"
Cohesion: 0.67
Nodes (4): create, debugGetCreateSourceHash, runBuild, _

### Community 72 - "Community 72"
Cohesion: 0.67
Nodes (4): create, debugGetCreateSourceHash, runBuild, _

### Community 98 - "Community 98"
Cohesion: 0.33
Nodes (5): main, ProviderScope, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_test/flutter_test.dart, package:polislot_mobile_catz/main.dart

## Knowledge Gaps
- **489 isolated node(s):** `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `PoliSlotApp`, `_PoliSlotAppState` (+484 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 17` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 5`, `Community 6`, `Community 7`, `Community 9`, `Community 10`, `Community 11`, `Community 13`, `Community 14`, `Community 15`, `Community 19`, `Community 20`, `Community 21`, `Community 22`, `Community 24`, `Community 25`, `Community 26`, `Community 27`, `Community 29`, `Community 34`, `Community 62`, `Community 63`, `Community 98`?**
  _High betweenness centrality (0.251) - this node is a cross-community bridge._
- **Why does `package:flutter_riverpod/flutter_riverpod.dart` connect `Community 98` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 5`, `Community 6`, `Community 9`, `Community 10`, `Community 11`, `Community 13`, `Community 14`, `Community 15`, `Community 17`, `Community 19`, `Community 21`, `Community 22`, `Community 24`, `Community 25`, `Community 26`, `Community 27`?**
  _High betweenness centrality (0.093) - this node is a cross-community bridge._
- **Why does `package:riverpod_annotation/riverpod_annotation.dart` connect `Community 18` to `Community 1`, `Community 2`, `Community 3`, `Community 7`, `Community 42`, `Community 43`, `Community 44`, `Community 13`, `Community 45`, `Community 46`, `Community 47`, `Community 11`, `Community 48`, `Community 23`, `Community 59`, `Community 28`, `Community 61`, `Community 30`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **What connects `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry` to the rest of the system?**
  _489 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._