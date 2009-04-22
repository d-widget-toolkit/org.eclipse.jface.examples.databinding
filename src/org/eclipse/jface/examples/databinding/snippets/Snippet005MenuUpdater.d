/*******************************************************************************
 * Copyright (c) 2006, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Brad Reynolds - bug 116920
 *******************************************************************************/
module org.eclipse.jface.examples.databinding.snippets.Snippet005MenuUpdater;

import java.lang.all;

import java.util.Date;
import java.util.Iterator;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.list.WritableList;
import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.jface.internal.databinding.provisional.swt.MenuUpdater;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Shell;

import tango.io.Stdout;

/**
 */
public class Snippet005MenuUpdater {
    public static void main(String[] args) {
        void add(Display d, WritableList menuItemStrings){
            Stdout.formatln("adding item");
            menuItemStrings.add(stringcast((new Date()).toString()));
            d.timerExec(5000, dgRunnable( &add, d, menuItemStrings ));
        }
        final Display display = new Display();
        Realm.runWithDefault(SWTObservables.getRealm(display), dgRunnable( (Display display_) {
            Shell shell = new Shell(display_);

            final WritableList menuItemStrings = new WritableList();
            display_.asyncExec(dgRunnable( &add, display_, menuItemStrings));

            Menu bar = new Menu(shell, SWT.BAR);
            shell.setMenuBar(bar);
            MenuItem fileItem = new MenuItem(bar, SWT.CASCADE);
            fileItem.setText("&Test Menu");
            final Menu submenu = new Menu(shell, SWT.DROP_DOWN);
            fileItem.setMenu(submenu);
            new class( submenu) MenuUpdater {
                this( Menu m ){
                    super(m);
                }
                protected void updateMenu() {
                    Stdout.formatln("updating menu");
                    MenuItem[] items = submenu.getItems();
                    int itemIndex = 0;
                    for (Iterator it = menuItemStrings.iterator(); it
                            .hasNext();) {
                        MenuItem item;
                        if (itemIndex < items.length) {
                            item = items[itemIndex++];
                        } else {
                            item = new MenuItem(submenu, SWT.NONE);
                        }
                        String string = stringcast( it.next());
                        item.setText(string);
                    }
                    while (itemIndex < items.length) {
                        items[itemIndex++].dispose();
                    }
                }
            };

            shell.open();

            // The SWT event loop
            while (!shell.isDisposed()) {
                if (!display_.readAndDispatch()) {
                    display_.sleep();
                }
            }
        }, display));
        display.dispose();
    }
}

void main( String[] args ){
    Snippet005MenuUpdater.main(args);
}

