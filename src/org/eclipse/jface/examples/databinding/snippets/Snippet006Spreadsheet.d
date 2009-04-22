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

module org.eclipse.jface.examples.databinding.snippets.Snippet006Spreadsheet;

import java.lang.all;
import tango.io.Stdout;

import java.text.NumberFormat;
import java.text.ParseException;

import org.eclipse.core.databinding.observable.Realm;
import org.eclipse.core.databinding.observable.list.WritableList;
import org.eclipse.core.databinding.observable.value.ComputedValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.WritableValue;
import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.jface.internal.databinding.provisional.swt.TableUpdater;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.ControlEditor;
import org.eclipse.swt.custom.TableCursor;
import org.eclipse.swt.events.KeyAdapter;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Text;

/**
 * @since 1.1
 * 
 */
public class Snippet006Spreadsheet {

    private static const int COUNTER_UPDATE_DELAY = 1000;

    private static const int NUM_COLUMNS = 6;

    private static const int NUM_ROWS = 16;

    /**
     * 0 for no output, 1 for some, 2 for more
     */
    private static int DEBUG_LEVEL = 0;

    /**
     * If true, there will be a automatic counter at B1.
     */
    private static bool FUNKY_COUNTER = false;

    /**
     * // * If true, all formulas (except for row 1 and column A) will be the
     * sum of the values of their left and top neighbouring cells.
     */
    private static bool FUNKY_FORMULAS = true;

    static WritableValue[][] cellFormulas;

    static ComputedValue[][] cellValues;

    static this(){
        cellFormulas = new WritableValue[][](NUM_ROWS,NUM_COLUMNS);
        cellValues = new ComputedValue[][](NUM_ROWS,NUM_COLUMNS);
    }

    static class ComputedCellValue : ComputedValue {
        private const IObservableValue cellFormula;

        private bool calculating;

        this(IObservableValue cellFormula) {
            this.cellFormula = cellFormula;
        }

        protected Object calculate() {
            if (calculating) {
                return stringcast("#cycle");
            }
            try {
                calculating = true;
                return evaluate(cellFormula.getValue());
            } finally {
                calculating = false;
            }
        }

        private Object evaluate(Object value) {
            if (DEBUG_LEVEL >= 2) {
                Stdout.formatln("evaluating {} ...", this);
            }
            if (value is null) {
                return stringcast("");
            }
            try {
                String s = stringcast( value );
                if (!s.startsWith("=")) {
                    return stringcast(s);
                }
                String addition = s.substring(1);
                int indexOfPlus = addition.indexOf('+');
                String operand1 = addition.substring(0, indexOfPlus);
                double value1 = eval(operand1);
                String operand2 = addition.substring(indexOfPlus + 1);
                double value2 = eval(operand2);
                return stringcast(NumberFormat.getNumberInstance().format(value1 + value2));
            } catch (Exception ex) {
                return stringcast(ex.msg);
            }
        }

        /**
         * @param s
         * @return
         * @throws ParseException
         */
        private double eval(String s) {
            if (s.length() is 0) {
                return 0;
            }
            dchar character = s.charAt(0);
            if (Character.isLetter(character)) {
                character = Character.toLowerCase(character);
                // reference to other cell
                int columnIndex = character - 'a';
                int rowIndex = 0;
                rowIndex = NumberFormat.getNumberInstance().parse(
                        s.substring(1)).intValue() - 1;
                String value = stringcast( cellValues[rowIndex][columnIndex]
                        .getValue());
                return value.length() is 0 ? 0 : NumberFormat
                        .getNumberInstance().parse(value).doubleValue();
            }
            return NumberFormat.getNumberInstance().parse(s).doubleValue();
        }
    }

    protected static int counter;
    static class LocalTableUpdater : TableUpdater {
        this( Table t, WritableList l ){
            super( t, l );
        }
        protected void updateItem(int rowIndex, TableItem item, Object element) {
            if (DEBUG_LEVEL >= 1) {
                Stdout.formatln("updating row {}", rowIndex);
            }
            for (int j = 0; j < NUM_COLUMNS; j++) {
                item.setText(j, stringcast( cellValues[rowIndex][j]
                        .getValue()));
            }
        }
    }
    static class CursorSelectionListener : SelectionAdapter {
        TableCursor cursor;
        Table table;
        ControlEditor editor;

        this(TableCursor c, Table t,ControlEditor e){
            cursor = c;
            table = t;
            editor = e;
        }
        // when the TableEditor is over a cell, select the
        // corresponding row
        // in
        // the table
        public void widgetSelected(SelectionEvent e) {
            table.setSelection([ cursor.getRow() ]);
        }

        // when the user hits "ENTER" in the TableCursor, pop up a
        // text
        // editor so that
        // they can change the text of the cell
        public void widgetDefaultSelected(SelectionEvent e) {
            final Text text = new Text(cursor, SWT.NONE);
            TableItem row = cursor.getRow();
            int rowIndex = table.indexOf(row);
            int columnIndex = cursor.getColumn();
            text
                    .setText(stringcast( cellFormulas[rowIndex][columnIndex]
                            .getValue()));
            text.addKeyListener(new TextKeyListener(table, cursor, text ));
            editor.setEditor(text);
            text.setFocus();
        }
    }
    static class TextKeyListener : KeyAdapter {
        Table table;
        TableCursor cursor;
        Text text;
        this(Table t, TableCursor c, Text t2){
            cursor = c;
            table = t;
            text = t2;
        }
        public void keyPressed(KeyEvent e) {
            // close the text editor and copy the data over
            // when the user hits "ENTER"
            if (e.character is SWT.CR) {
                TableItem row = cursor.getRow();
                int rowIndex = table.indexOf(row);
                int columnIndex = cursor.getColumn();
                cellFormulas[rowIndex][columnIndex]
                    .setValue(stringcast(text.getText()));
                text.dispose();
            }
            // close the text editor when the user hits
            // "ESC"
            if (e.character is SWT.ESC) {
                text.dispose();
            }
        }
    }
    static class CursorKeyListener : KeyAdapter {
        TableCursor cursor;
        this(TableCursor c){
            cursor = c;
        }
        public void keyPressed(KeyEvent e) {
            if (e.keyCode is SWT.MOD1 || e.keyCode is SWT.MOD2
                    || (e.stateMask & SWT.MOD1) !is 0
                    || (e.stateMask & SWT.MOD2) !is 0) {
                cursor.setVisible(false);
            }
        }
    }
    static class TableKeyListener : KeyAdapter {
        Table table;
        TableCursor cursor;
        this(Table t, TableCursor c){
            cursor = c;
            table = t;
        }
        public void keyReleased(KeyEvent e) {
            if (e.keyCode is SWT.MOD1
                    && (e.stateMask & SWT.MOD2) !is 0)
                return;
            if (e.keyCode is SWT.MOD2
                    && (e.stateMask & SWT.MOD1) !is 0)
                return;
            if (e.keyCode !is SWT.MOD1
                    && (e.stateMask & SWT.MOD1) !is 0)
                return;
            if (e.keyCode !is SWT.MOD2
                    && (e.stateMask & SWT.MOD2) !is 0)
                return;

            TableItem[] selection = table.getSelection();
            TableItem row = (selection.length is 0) ? table
                .getItem(table.getTopIndex()) : selection[0];
            table.showItem(row);
            cursor.setSelection(row, 0);
            cursor.setVisible(true);
            cursor.setFocus();
        }
    }
    public static void main(String[] args) {

        final Display display = new Display();
        Realm.runWithDefault(SWTObservables.getRealm(display), dgRunnable( (Display display_) {
                Shell shell = new Shell(display_);
                shell.setText("Data Binding Snippet 006");

                final Table table = new Table(shell, SWT.BORDER | SWT.MULTI
                        | SWT.FULL_SELECTION | SWT.VIRTUAL);
                table.setLinesVisible(true);
                table.setHeaderVisible(true);

                for (int i = 0; i < NUM_COLUMNS; i++) {
                    TableColumn tableColumn = new TableColumn(table, SWT.NONE);
                    tableColumn.setText(Character.toString(cast(char) ('A' + i)));
                    tableColumn.setWidth(60);
                }
                WritableList list = new WritableList();
                for (int i = 0; i < NUM_ROWS; i++) {
                    list.add(new Object());
                    for (int j = 0; j < NUM_COLUMNS; j++) {
                        cellFormulas[i][j] = new WritableValue();
                        cellValues[i][j] = new ComputedCellValue(
                                cellFormulas[i][j]);
                        if (!FUNKY_FORMULAS || i is 0 || j is 0) {
                            cellFormulas[i][j].setValue(stringcast(""));
                        } else {
                            cellFormulas[i][j].setValue(stringcast("="
                                    ~ cellReference(i - 1, j) ~ "+"
                                    ~ cellReference(i, j - 1)));
                        }
                    }
                }

                new LocalTableUpdater( table, list );

                if (FUNKY_COUNTER) {
                    // counter in A1
                    display_.asyncExec(dgRunnable(&output, display_));
                }

                // create a TableCursor to navigate around the table
                final TableCursor cursor = new TableCursor(table, SWT.NONE);
                // create an editor to edit the cell when the user hits "ENTER"
                // while over a cell in the table
                final ControlEditor editor = new ControlEditor(cursor);
                editor.grabHorizontal = true;
                editor.grabVertical = true;

                cursor.addSelectionListener(new CursorSelectionListener( cursor, table, editor ));
                // Hide the TableCursor when the user hits the "MOD1" or "MOD2"
                // key.
                // This alows the user to select multiple items in the table.
                cursor.addKeyListener(new CursorKeyListener(cursor) );
                // Show the TableCursor when the user releases the "MOD2" or
                // "MOD1" key.
                // This signals the end of the multiple selection task.
                table.addKeyListener(new TableKeyListener(table, cursor));

                GridLayoutFactory.fillDefaults().generateLayout(shell);
                shell.setSize(400, 300);
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
    private void output( Display display ){
        cellFormulas[0][1].setValue(stringcast(Format("{}", counter++)));
        display.timerExec(COUNTER_UPDATE_DELAY, dgRunnable( &output, display ));
    }

    private static String cellReference(int rowIndex, int columnIndex) {
        String cellReference = Format("{}{}", (cast(char) ('A' + columnIndex))
                , (rowIndex + 1));
        return cellReference;
    }

}

void main( String[] args ){
    Snippet006Spreadsheet.main(args);
}
