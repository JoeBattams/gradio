gnome = import('gnome')

ver = vcs_tag(input : 'version.vala.in', output : 'version.vala',
              command : ['sh', '../print_git_version.sh'],
              fallback : meson.project_version())



res = gnome.compile_resources('gt-resources', '../data/de.haeckerfelix.gradio.gresource.xml', source_dir : '../data')

libgtk_dep = dependency('gtk+-3.0', version : '>=3.20')

deps_gradio = [libgtk_dep,
           dependency('libsoup-2.4'),
           dependency('json-glib-1.0'),
           dependency('gstreamer-1.0'),
           dependency('glib-2.0'),
           dependency('gobject-2.0'),
           dependency('sqlite3'),
           dependency('gstreamer-pbutils-1.0')]

cc = meson.get_compiler('c')
deps_gradio += cc.find_library('m', required: false)

src_gradio = ['gradio-app.vala',
	      'gradio-additional-data-provider.vala',
	      'gradio-page.vala',
	      'gradio-audio-player.vala',
	      'gradio-category-item-provider.vala',
	      'gradio-codec-installer.vala',
	      'gradio-image-provider.vala',
	      'gradio-library.vala',
	      'gradio-main-window.vala',
	      'gradio-mpris.vala',
	      'gradio-player-toolbar.vala',
	      'gradio-radio-browser.vala',
	      'gradio-radio-station-provider.vala',
	      'gradio-radio-station.vala',
	      'gradio-search-page.vala',
	      'gradio-settings-dialog.vala',
	      'gradio-settings.vala',
	      'gradio-station-model.vala',
	      'gradio-stations-view-grid-item.vala',
	      'gradio-stations-view-list-item.vala',
	      'gradio-station-view.vala',
	      'gradio-status-label.vala',
	      'gradio-library-page.vala',
	      'gradio-discover-page.vala',
	      'gradio-station-detail-page.vala',
	      'gradio-utils.vala',
	      res,
              ver]

executable('gradio', src_gradio, vala_args : '--target-glib=2.38 -X',
           dependencies : deps_gradio,
           install : true)

