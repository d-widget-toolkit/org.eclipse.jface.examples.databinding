/*******************************************************************************
 * Copyright (c) 2007 Brad Reynolds and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Brad Reynolds - initial API and implementation
 *     Matthew Hall - bug 260329
 ******************************************************************************/

module org.eclipse.jface.examples.databinding.snippets.Snippet010MasterDetail;

import java.lang.all;

import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;

import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.beans.BeansObservables;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.jface.databinding.viewers.ViewersObservables;
import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ListViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

/**
 * Snippet that displays a simple master detail use case. A list of persons is
 * displayed in a list and upon selection the name of the selected person will
 * be displayed in a Text widget.
 */
public class Snippet010MasterDetail {
    public static void main(String[] args) {
        final Display display = new Display();
        Realm.runWithDefault(SWTObservables.getRealm(display), dgRunnable(() {
            Shell shell = new Shell(display);
            shell.setLayout(new GridLayout());

            Person[] persons = [ new Person("Me"),
                    new Person("Myself"), new Person("I") ];

            ListViewer viewer = new ListViewer(shell);
            viewer.setContentProvider(new ArrayContentProvider!(Object)());
            viewer.setInput(new ArrayWrapperObject(persons));

            Text name = new Text(shell, SWT.BORDER | SWT.READ_ONLY);

            // 1. Observe changes in selection.
            IObservableValue selection = ViewersObservables
                    .observeSingleSelection(cast(Viewer)viewer);

            // 2. Observe the name property of the current selection.
            IObservableValue detailObservable = BeansObservables
                    .observeDetailValue(SWTObservables.getRealm(display), selection, "name", Class.fromType!(String));

            // 3. Bind the Text widget to the name detail (selection's
            // name).
            (new DataBindingContext()).bindValue(SWTObservables.observeText(
                    name, SWT.None), detailObservable,
                    new UpdateValueStrategy(false,
                            UpdateValueStrategy.POLICY_NEVER), null);

            shell.open();
            while (!shell.isDisposed()) {
                if (!display.readAndDispatch())
                    display.sleep();
            }
        }));
        display.dispose();
    }

    public static class Person {
        private String name;
        private PropertyChangeSupport changeSupport;

        this(String name) {
        changeSupport = new PropertyChangeSupport(this);
            this.name = name;
        }

        public void addPropertyChangeListener(PropertyChangeListener listener) {
            changeSupport.addPropertyChangeListener(listener);
        }
        
        public void removePropertyChangeListener(PropertyChangeListener listener) {
            changeSupport.removePropertyChangeListener(listener);
        }
        
        /**
         * @return Returns the name.
         */
        public String getName() {
            return name;
        }

        public String toString() {
            return name;
        }
    }
}
void main( String[] args ){
    Snippet010MasterDetail.main(args);
}
