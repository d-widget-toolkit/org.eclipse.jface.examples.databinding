/*******************************************************************************
 * Copyright (c) 2006 The Pampered Chef, Inc. and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Coconut Palm Software, Inc. - Initial API and implementation
 *     Matthew Hall - bug 260337
 ******************************************************************************/

module org.eclipse.jface.examples.databinding.snippets.Snippet009TableViewer;

import java.lang.all;

import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.util.LinkedList;
import java.util.List;

//import org.eclipse.core.databinding.beans.BeanProperties;
import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.beans.BeansObservables;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.list.WritableList;
import org.eclipse.core.databinding.observable.map.IObservableMap;
import org.eclipse.jface.databinding.swt.SWTObservables;
//import org.eclipse.jface.databinding.viewers.ViewerSupport;
import org.eclipse.jface.databinding.viewers.ObservableListContentProvider;
import org.eclipse.jface.databinding.viewers.ObservableMapLabelProvider;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;

/**
 * Demonstrates binding a TableViewer to a collection.
 */
public class Snippet009TableViewer {
    public static void main(String[] args) {
        final Display display = Display.getDefault();

        // In an RCP application, the threading Realm will be set for you
        // automatically by the Workbench. In an SWT application, you can do
        // this once, wrpping your binding method call.
        Realm.runWithDefault(SWTObservables.getRealm(display), dgRunnable(() {

            ViewModel viewModel = new ViewModel();
            Shell shell = (new View(viewModel)).createShell();

            // The SWT event loop
            while (!shell.isDisposed()) {
                if (!display.readAndDispatch()) {
                    display.sleep();
                }
            }
        }));
    }

    // Minimal JavaBeans support
    public static abstract class AbstractModelObject {
        private PropertyChangeSupport propertyChangeSupport;
        this(){
            propertyChangeSupport = new PropertyChangeSupport(
                this);
        }

        public void addPropertyChangeListener(PropertyChangeListener listener) {
            propertyChangeSupport.addPropertyChangeListener(listener);
        }

        public void addPropertyChangeListener(String propertyName,
                PropertyChangeListener listener) {
            propertyChangeSupport.addPropertyChangeListener(propertyName,
                    listener);
        }

        public void removePropertyChangeListener(PropertyChangeListener listener) {
            propertyChangeSupport.removePropertyChangeListener(listener);
        }

        public void removePropertyChangeListener(String propertyName,
                PropertyChangeListener listener) {
            propertyChangeSupport.removePropertyChangeListener(propertyName,
                    listener);
        }

        protected void firePropertyChange(String propertyName, Object oldValue,
                Object newValue) {
            propertyChangeSupport.firePropertyChange(propertyName, oldValue,
                    newValue);
        }
    }

    // The data model class. This is normally a persistent class of some sort.
    static class Person : AbstractModelObject {
        // A property...
        String name = "John Smith";

        public this(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            String oldValue = this.name;
            this.name = name;
            firePropertyChange("name", stringcast(oldValue), stringcast(name));
        }
    }

    // The View's model--the root of our Model graph for this particular GUI.
    //
    // Typically each View class has a corresponding ViewModel class.
    // The ViewModel is responsible for getting the objects to edit from the
    // data access tier. Since this snippet doesn't have any persistent objects
    // ro retrieve, this ViewModel just instantiates a model object to edit.
    static class ViewModel {
        // The model to bind
        private List people;
        this(){
            people = new LinkedList();
            people.add(new Person("Steve Northover"));
            people.add(new Person("Grant Gayed"));
            people.add(new Person("Veronika Irvine"));
            people.add(new Person("Mike Wilson"));
            people.add(new Person("Christophe Cornu"));
            people.add(new Person("Lynne Kues"));
            people.add(new Person("Silenio Quarti"));
        }

        public List getPeople() {
            return people;
        }
    }

    // The GUI view
    static class View {
        private ViewModel viewModel;
        private Table committers;

        public this(ViewModel viewModel) {
            this.viewModel = viewModel;
        }

        public Shell createShell() {
            // Build a UI
            Display display = Display.getDefault();
            Shell shell = new Shell(display);
            shell.setLayout(new FillLayout());
            committers = new Table(shell, SWT.BORDER | SWT.FULL_SELECTION);
            committers.setLinesVisible(true);
            TableColumn column = new TableColumn(committers, SWT.NONE);

            // Set up data binding.
            TableViewer peopleViewer = new TableViewer(committers);

            ///ViewerSupport.bind(peopleViewer, new WritableList(viewModel
            ///        .getPeople(), Class.fromType!(Person)), BeanProperties.value(
            ///        Class.fromType!(Person), "name"));

            // Create a standard content provider
            ObservableListContentProvider peopleViewerContentProvider =
                new ObservableListContentProvider();
            peopleViewer.setContentProvider(peopleViewerContentProvider);

            // And a standard label provider that maps columns
            IObservableMap[] attributeMaps = BeansObservables.observeMaps(
                    peopleViewerContentProvider.getKnownElements(), Class.fromType!(Person),
                    [ "name" ]);
            peopleViewer.setLabelProvider(new ObservableMapLabelProvider(attributeMaps));

            // Now set the Viewer's input
            peopleViewer.setInput(new WritableList(viewModel.getPeople(), Class.fromType!(Person)));

            column.pack();

            // Open and return the Shell
            shell.setSize(100, 300);
            shell.open();
            return shell;
        }
    }

}

void main( String[] args ){
    Snippet009TableViewer.main(args);
}
