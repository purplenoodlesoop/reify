import 'dart:async';
import 'dart:developer';

import 'package:mark/mark.dart';
import 'package:pure/pure.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:vm_service/utils.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

typedef _Reload = Future<bool> Function();

StreamSubscription<void> watchForHotReload(
  Logger logger, {
  required Set<String> paths,
  required FutureOr<void> Function() onReload,
}) {
  Future<_Reload> createReload() async {
    final serverUri = (await Service.getInfo()).serverUri;
    if (serverUri == null) {
      throw StateError('No VM service. Run with --enable-vm-service');
    }
    final service = await convertToWebSocketUrl(serviceProtocolUrl: serverUri)
        .toString()
        .pipe(vmServiceConnectUri);
    final vm = await service.getVM();

    return () async {
      final reports = await vm.isolates
          ?.map((ref) => ref.id)
          .pipe(Stream.fromIterable)
          .whereNotNull()
          .asyncMap(service.reloadSources)
          .toList();
      if (reports == null) {
        logger.warning('Failed obtain isolates on the current VM');

        return false;
      }

      return reports.every((report) => report.success ?? false);
    };
  }

  Stream<void> reloadEvents(_Reload reload) => Stream.fromIterable(paths)
      .concurrentAsyncExpand((path) => DirectoryWatcher(path).events)
      .asyncMap((event) {
        logger.debug(
          'Detected change',
          meta: (
            type: event.type,
            path: event.path,
          ),
        );

        return reload();
      })
      .where(id)
      .asyncMap((event) => onReload())
      .map((event) => logger.debug('Reloaded'));

  final subscription = createReload()
      .asStream()
      .concurrentAsyncExpand(reloadEvents)
      .listen(null);
  logger.debug('Watching for changes for hot reload', meta: (paths: paths));

  return subscription;
}
