module.exports = (gulp, paths, $, _, options, tasks) => {
    const interval = { interval: 500 };

    gulp.watch(_.files(paths.src.styles), interval, gulp.series(tasks.styles));
    // gulp.watch(_.folder(paths.src) + '/index.html', interval, tasks.copy);
    gulp.watch (_.folder(paths.src.views), interval, gulp.series (tasks.pug));
    gulp.watch(_.files(paths.src.assets.images), interval, tasks.assets);
};