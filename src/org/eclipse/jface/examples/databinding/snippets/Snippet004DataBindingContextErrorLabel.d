/*******************************************************************************
 * Copyright (c) 2006 Brad Reynolds and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Brad Reynolds - initial API and implementation
 *     Brad Reynolds - bug 116920, 159768
 *     Matthew Hall - bug 260329
 ******************************************************************************/

module org.eclipse.jface.examples.databinding.snippets.Snippet004DataBindingContextErrorLabel;

import java.lang.all;
import org.eclipse.core.databinding.AggregateValidationStatus;
import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.core.databinding.validation.IValidator;
import org.eclipse.core.databinding.validation.ValidationStatus;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.jface.layout.GridDataFactory;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

/**
 * Snippet that displays how to bind the validation error of the
 * {@link DataBindingContext} to a label. http://www.eclipse.org
 * 
 * @since 3.2
 */
public class Snippet004DataBindingContextErrorLabel {
    public static void main(String[] args) {
        Display display = new Display();
        Realm.runWithDefault(SWTObservables.getRealm(display), dgRunnable( ( Display display_){
            Shell shell = new Shell(display_);
            shell.setText("Data Binding Snippet 004");
            shell.setLayout(new GridLayout(2, false));

            (new Label(shell, SWT.NONE)).setText("Enter '5' to be valid:");

            Text text = new Text(shell, SWT.BORDER);
            WritableValue value = WritableValue.withValueType(Class.fromType!(String));
            (new Label(shell, SWT.NONE)).setText("Error:");

            Label errorLabel = new Label(shell, SWT.BORDER);
            errorLabel.setForeground(display_.getSystemColor(SWT.COLOR_RED));
            GridDataFactory.swtDefaults().hint(200, SWT.DEFAULT).applyTo(
                    errorLabel);

            DataBindingContext dbc = new DataBindingContext();

            // Bind the text to the value.
            dbc.bindValue(
                    SWTObservables.observeText(text, SWT.Modify),
                    value,
                    (new UpdateValueStrategy()).setAfterConvertValidator(new FiveValidator()),
                    null);

            // Bind the error label to the validation error on the dbc.
            dbc.bindValue(SWTObservables.observeText(errorLabel),
                    new AggregateValidationStatus(dbc.getBindings(),
                            AggregateValidationStatus.MAX_SEVERITY), null, null);
                            // DWT: is overloading in newer version
                            //AggregateValidationStatus.MAX_SEVERITY));

            shell.pack();
            shell.open();
            while (!shell.isDisposed()) {
                if (!display_.readAndDispatch())
                    display_.sleep();
            }
        }, display));
        display.dispose();
    }

    /**
     * Validator that returns validation errors for any value other than 5.
     * 
     * @since 3.2
     */
    private static class FiveValidator : IValidator {
        public IStatus validate(Object value) {
            return ("5".equals(stringcast(value))) ? Status.OK_STATUS : ValidationStatus
                    .error(Format("the value was '{}', not '5'", value ));
        }
    }
}

void main( String[] args ){
    Snippet004DataBindingContextErrorLabel.main( args );
}
