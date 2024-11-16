#!/usr/bin/python3
import shutil
import subprocess
import urllib.parse
import locale

from gi import require_version

require_version("Nautilus", "4.0")
require_version("Gtk", "4.0")

TERMINAL_NAME = "org.gnome.Console"

import logging
import os
from gettext import gettext

from gi.repository import GObject, Nautilus

if os.environ.get("NAUTILUS_KGX_DEBUG", "False") == "True":
    logging.basicConfig(level=logging.DEBUG)


class KGXNautilus(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()
        self.is_select = False

    def get_file_items(self, files: list[Nautilus.FileInfo]):
        """Return to menu when click on any file/folder."""
        if not self.only_one_file_info(files):
            return []

        menu = []
        fileInfo = files[0]
        self.is_select = False

        if fileInfo.is_directory():
            self.is_select = True
            dir_path = self.get_abs_path(fileInfo)

            logging.debug("Selecting a directory!!")
            logging.debug(f"Create a menu item for entry {dir_path}")
            menu_item = self._create_nautilus_item(dir_path)
            menu.append(menu_item)

        return menu

    def get_background_items(self, directory):
        """Returns the menu items to display when no file/folder is selected."""
        if self.is_select:
            self.is_select = False
            return []

        menu = []
        if directory.is_directory():
            dir_path = self.get_abs_path(directory)

            logging.debug("Nothing is selected. Launch from background!!")
            logging.debug(f"Create a menu item for entry {dir_path}")
            menu_item = self._create_nautilus_item(dir_path)
            menu.append(menu_item)

        return menu

    def _create_nautilus_item(self, dir_path: str) -> Nautilus.MenuItem:
        """Creates the 'Open In Console' menu item."""
        match locale.getlocale()[0].split("_")[0]:
            case "zh":
                text_label = "在 Console 打开"
            case "fr":
                text_label = "Ouvrir dans Console"
            case "ar":
                text_label = "(Console) الفتح في المحطة"
            case "pt":
                text_label = "Abrir no Console"
            case _:
                text_label = "Open in Console"
        match locale.getlocale()[0].split("_")[0]:
            case "fr":
                text_tip = "Ouvrir ce fichier/dossier dans Console"
            case "pt":
                text_tip = "Abrir esta pasta/arquivo no Console"
            case _:
                text_tip = "Open this folder/file in Console"

        item = Nautilus.MenuItem(
            name="KGXNautilus::open_in_kgx",
            label=gettext(text_label),
            tip=gettext(text_tip),
        )
        logging.debug(f"Created item with path {dir_path}")

        item.connect("activate", self._nautilus_run, dir_path)
        logging.debug("Connect trigger to menu item")

        return item

    def is_native(self):
        if shutil.which("kgx") == "/usr/bin/kgx":
            return "kgx"

    def _nautilus_run(self, menu, path):
        """'Open with GNOME Console' menu item callback."""
        logging.debug("Opening:", path)
        args = None
        if self.is_native() == "kgx":
            args = ["kgx", "--working-directory", path]
        else:
            args = ["/usr/bin/flatpak", "run", TERMINAL_NAME, "--working-directory", path]

        subprocess.Popen(args, cwd=path)

    def get_abs_path(self, fileInfo: Nautilus.FileInfo):
        path = fileInfo.get_location().get_path()
        return path

    def only_one_file_info(self, files: list[Nautilus.FileInfo]):
        return len(files) == 1
