// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'5a6430ca855c590aff1350743cd4f617eda201f8';

/// See also [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$projectDaoHash() => r'dbfd124760e33bf7565607d27b19e28a4d2d531b';

/// See also [projectDao].
@ProviderFor(projectDao)
final projectDaoProvider = AutoDisposeProvider<ProjectDao>.internal(
  projectDao,
  name: r'projectDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$projectDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProjectDaoRef = AutoDisposeProviderRef<ProjectDao>;
String _$taskDaoHash() => r'f161ccd94b279c03c3cfa421b52429a839a2818b';

/// See also [taskDao].
@ProviderFor(taskDao)
final taskDaoProvider = AutoDisposeProvider<TaskDao>.internal(
  taskDao,
  name: r'taskDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskDaoRef = AutoDisposeProviderRef<TaskDao>;
String _$allProjectsHash() => r'33fa5e861631a86ae93956cafa3f70fb52ebf8e4';

/// See also [allProjects].
@ProviderFor(allProjects)
final allProjectsProvider = AutoDisposeStreamProvider<List<Project>>.internal(
  allProjects,
  name: r'allProjectsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allProjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllProjectsRef = AutoDisposeStreamProviderRef<List<Project>>;
String _$projectByIdHash() => r'f2d27ddcdd70188edccda50063c2c7191df0f90c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [projectById].
@ProviderFor(projectById)
const projectByIdProvider = ProjectByIdFamily();

/// See also [projectById].
class ProjectByIdFamily extends Family<AsyncValue<Project?>> {
  /// See also [projectById].
  const ProjectByIdFamily();

  /// See also [projectById].
  ProjectByIdProvider call(
    int id,
  ) {
    return ProjectByIdProvider(
      id,
    );
  }

  @override
  ProjectByIdProvider getProviderOverride(
    covariant ProjectByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectByIdProvider';
}

/// See also [projectById].
class ProjectByIdProvider extends AutoDisposeStreamProvider<Project?> {
  /// See also [projectById].
  ProjectByIdProvider(
    int id,
  ) : this._internal(
          (ref) => projectById(
            ref as ProjectByIdRef,
            id,
          ),
          from: projectByIdProvider,
          name: r'projectByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectByIdHash,
          dependencies: ProjectByIdFamily._dependencies,
          allTransitiveDependencies:
              ProjectByIdFamily._allTransitiveDependencies,
          id: id,
        );

  ProjectByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    Stream<Project?> Function(ProjectByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectByIdProvider._internal(
        (ref) => create(ref as ProjectByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Project?> createElement() {
    return _ProjectByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectByIdRef on AutoDisposeStreamProviderRef<Project?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _ProjectByIdProviderElement
    extends AutoDisposeStreamProviderElement<Project?> with ProjectByIdRef {
  _ProjectByIdProviderElement(super.provider);

  @override
  int get id => (origin as ProjectByIdProvider).id;
}

String _$tasksByProjectHash() => r'096ac84c2b368578714f3071f23e21e968d3aa33';

/// See also [tasksByProject].
@ProviderFor(tasksByProject)
const tasksByProjectProvider = TasksByProjectFamily();

/// See also [tasksByProject].
class TasksByProjectFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [tasksByProject].
  const TasksByProjectFamily();

  /// See also [tasksByProject].
  TasksByProjectProvider call(
    int projectId,
  ) {
    return TasksByProjectProvider(
      projectId,
    );
  }

  @override
  TasksByProjectProvider getProviderOverride(
    covariant TasksByProjectProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksByProjectProvider';
}

/// See also [tasksByProject].
class TasksByProjectProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// See also [tasksByProject].
  TasksByProjectProvider(
    int projectId,
  ) : this._internal(
          (ref) => tasksByProject(
            ref as TasksByProjectRef,
            projectId,
          ),
          from: tasksByProjectProvider,
          name: r'tasksByProjectProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tasksByProjectHash,
          dependencies: TasksByProjectFamily._dependencies,
          allTransitiveDependencies:
              TasksByProjectFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  TasksByProjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final int projectId;

  @override
  Override overrideWith(
    Stream<List<Task>> Function(TasksByProjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksByProjectProvider._internal(
        (ref) => create(ref as TasksByProjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _TasksByProjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByProjectProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksByProjectRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `projectId` of this provider.
  int get projectId;
}

class _TasksByProjectProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>>
    with TasksByProjectRef {
  _TasksByProjectProviderElement(super.provider);

  @override
  int get projectId => (origin as TasksByProjectProvider).projectId;
}

String _$projectProgressHash() => r'dc2de4846d387d94351100ef8488831d6778eabf';

/// See also [projectProgress].
@ProviderFor(projectProgress)
const projectProgressProvider = ProjectProgressFamily();

/// See also [projectProgress].
class ProjectProgressFamily extends Family<AsyncValue<ProjectProgress>> {
  /// See also [projectProgress].
  const ProjectProgressFamily();

  /// See also [projectProgress].
  ProjectProgressProvider call(
    int projectId,
  ) {
    return ProjectProgressProvider(
      projectId,
    );
  }

  @override
  ProjectProgressProvider getProviderOverride(
    covariant ProjectProgressProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectProgressProvider';
}

/// See also [projectProgress].
class ProjectProgressProvider
    extends AutoDisposeStreamProvider<ProjectProgress> {
  /// See also [projectProgress].
  ProjectProgressProvider(
    int projectId,
  ) : this._internal(
          (ref) => projectProgress(
            ref as ProjectProgressRef,
            projectId,
          ),
          from: projectProgressProvider,
          name: r'projectProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectProgressHash,
          dependencies: ProjectProgressFamily._dependencies,
          allTransitiveDependencies:
              ProjectProgressFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  ProjectProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final int projectId;

  @override
  Override overrideWith(
    Stream<ProjectProgress> Function(ProjectProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectProgressProvider._internal(
        (ref) => create(ref as ProjectProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ProjectProgress> createElement() {
    return _ProjectProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectProgressProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectProgressRef on AutoDisposeStreamProviderRef<ProjectProgress> {
  /// The parameter `projectId` of this provider.
  int get projectId;
}

class _ProjectProgressProviderElement
    extends AutoDisposeStreamProviderElement<ProjectProgress>
    with ProjectProgressRef {
  _ProjectProgressProviderElement(super.provider);

  @override
  int get projectId => (origin as ProjectProgressProvider).projectId;
}

String _$completedTaskCountHash() =>
    r'a6d8b59fb3ef81d6017573a3c350b1ceb980aae2';

/// See also [completedTaskCount].
@ProviderFor(completedTaskCount)
const completedTaskCountProvider = CompletedTaskCountFamily();

/// See also [completedTaskCount].
class CompletedTaskCountFamily extends Family<int> {
  /// See also [completedTaskCount].
  const CompletedTaskCountFamily();

  /// See also [completedTaskCount].
  CompletedTaskCountProvider call(
    int projectId,
  ) {
    return CompletedTaskCountProvider(
      projectId,
    );
  }

  @override
  CompletedTaskCountProvider getProviderOverride(
    covariant CompletedTaskCountProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'completedTaskCountProvider';
}

/// See also [completedTaskCount].
class CompletedTaskCountProvider extends AutoDisposeProvider<int> {
  /// See also [completedTaskCount].
  CompletedTaskCountProvider(
    int projectId,
  ) : this._internal(
          (ref) => completedTaskCount(
            ref as CompletedTaskCountRef,
            projectId,
          ),
          from: completedTaskCountProvider,
          name: r'completedTaskCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$completedTaskCountHash,
          dependencies: CompletedTaskCountFamily._dependencies,
          allTransitiveDependencies:
              CompletedTaskCountFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  CompletedTaskCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final int projectId;

  @override
  Override overrideWith(
    int Function(CompletedTaskCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CompletedTaskCountProvider._internal(
        (ref) => create(ref as CompletedTaskCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<int> createElement() {
    return _CompletedTaskCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedTaskCountProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CompletedTaskCountRef on AutoDisposeProviderRef<int> {
  /// The parameter `projectId` of this provider.
  int get projectId;
}

class _CompletedTaskCountProviderElement extends AutoDisposeProviderElement<int>
    with CompletedTaskCountRef {
  _CompletedTaskCountProviderElement(super.provider);

  @override
  int get projectId => (origin as CompletedTaskCountProvider).projectId;
}

String _$projectCompletionRateHash() =>
    r'cd5646ef267fea6a3c4a01f11e550ba1368850b7';

/// See also [projectCompletionRate].
@ProviderFor(projectCompletionRate)
const projectCompletionRateProvider = ProjectCompletionRateFamily();

/// See also [projectCompletionRate].
class ProjectCompletionRateFamily extends Family<double> {
  /// See also [projectCompletionRate].
  const ProjectCompletionRateFamily();

  /// See also [projectCompletionRate].
  ProjectCompletionRateProvider call(
    int projectId,
  ) {
    return ProjectCompletionRateProvider(
      projectId,
    );
  }

  @override
  ProjectCompletionRateProvider getProviderOverride(
    covariant ProjectCompletionRateProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectCompletionRateProvider';
}

/// See also [projectCompletionRate].
class ProjectCompletionRateProvider extends AutoDisposeProvider<double> {
  /// See also [projectCompletionRate].
  ProjectCompletionRateProvider(
    int projectId,
  ) : this._internal(
          (ref) => projectCompletionRate(
            ref as ProjectCompletionRateRef,
            projectId,
          ),
          from: projectCompletionRateProvider,
          name: r'projectCompletionRateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectCompletionRateHash,
          dependencies: ProjectCompletionRateFamily._dependencies,
          allTransitiveDependencies:
              ProjectCompletionRateFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  ProjectCompletionRateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final int projectId;

  @override
  Override overrideWith(
    double Function(ProjectCompletionRateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectCompletionRateProvider._internal(
        (ref) => create(ref as ProjectCompletionRateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _ProjectCompletionRateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectCompletionRateProvider &&
        other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectCompletionRateRef on AutoDisposeProviderRef<double> {
  /// The parameter `projectId` of this provider.
  int get projectId;
}

class _ProjectCompletionRateProviderElement
    extends AutoDisposeProviderElement<double> with ProjectCompletionRateRef {
  _ProjectCompletionRateProviderElement(super.provider);

  @override
  int get projectId => (origin as ProjectCompletionRateProvider).projectId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
