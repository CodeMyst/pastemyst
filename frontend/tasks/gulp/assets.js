module.exports = (gulp, paths, $, _) => {
    let dest = _.folder(paths.dist.assets.images);
    gulp.src(_.files(paths.src.assets.images))
        .pipe($.newer(dest))
        .pipe($.imagemin())
        .pipe(gulp.dest(dest));

    let dest2 = _.folder(paths.dist.assets.fonts);
    gulp.src(_.files(paths.src.assets.fonts))
        .pipe($.newer(dest2))
        .pipe($.fontmin())
        .pipe(gulp.dest(dest2));

    let dest3 = _.folder(paths.dist.assets.icons);
    return gulp.src(_.files(paths.src.assets.icons))
        .pipe($.newer(dest3))
        .pipe(gulp.dest(dest3));
};