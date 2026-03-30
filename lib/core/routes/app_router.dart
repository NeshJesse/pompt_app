import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../layout/app_layout.dart';
import 'package:pompt_app/screens/dashboard/kanban.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppLayout(),
        routes: [
          // Kanban pushes on top of AppLayout — no sidebar visible
          GoRoute(
            path: 'projects/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return KanbanScreen(projectId: id);
            },
          ),
        ],
      ),
    ],
  );
}
