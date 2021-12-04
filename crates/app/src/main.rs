use std::{env, path::PathBuf, thread};

use sabi_binarizer::Binarizer;
use sabi_commands::CommandParser;
use sabi_core::App;
use sabi_filesystem::library_filename;
use sabi_launcher::launcher::Launcher;
use sabi_resources::Data;

fn main() {
    env::set_current_dir(".").ok();

    let mut app = App::default();

    let mut binarizer = Binarizer::new(
        app.get_global_messenger(),
        Data::data_raw_folder(),
        Data::data_folder(),
    );
    binarizer.start();

    //additional plugins
    let command_parser = CommandParser::from_command_line();
    let plugins = command_parser.get_values_of::<String>("plugin");

    let mut launcher = Launcher::default();
    launcher.prepare(&mut app);

    for name in plugins.iter() {
        let path = PathBuf::from(library_filename(name));
        launcher.read_config(&mut app, name);
        app.add_plugin(path);
    }

    app.start();

    while !binarizer.is_running() {
        thread::yield_now();
    }

    loop {
        let can_continue = app.run_once();

        if !can_continue {
            break;
        }
    }

    launcher.unprepare(&mut app);

    binarizer.stop();
}