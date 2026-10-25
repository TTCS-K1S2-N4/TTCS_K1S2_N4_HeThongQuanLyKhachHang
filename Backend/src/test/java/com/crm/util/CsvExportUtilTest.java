package com.crm.util;

import com.crm.controller.customer.CustomerExportServlet;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CsvExportUtilTest {

    @Test
    void testEscapeCsvField_NormalText() {
        assertEquals("Nguyen Van A", CustomerExportServlet.escapeCsvField("Nguyen Van A"));
    }

    @Test
    void testEscapeCsvField_ValidNegativeNumber() {
        assertEquals("-100", CustomerExportServlet.escapeCsvField("-100"));
        assertEquals("-45.50", CustomerExportServlet.escapeCsvField("-45.50"));
    }

    @Test
    void testEscapeCsvField_FormulaInjectionSymbols() {
        assertEquals("'=1+2", CustomerExportServlet.escapeCsvField("=1+2"));
        assertEquals("'+cmd|' /C calc'!A0", CustomerExportServlet.escapeCsvField("+cmd|' /C calc'!A0"));
        assertEquals("'-100+cmd", CustomerExportServlet.escapeCsvField("-100+cmd"));
        assertEquals("'@SUM(A1:A10)", CustomerExportServlet.escapeCsvField("@SUM(A1:A10)"));
    }

    @Test
    void testEscapeCsvField_NullOrEmpty() {
        assertEquals("", CustomerExportServlet.escapeCsvField(null));
        assertEquals("", CustomerExportServlet.escapeCsvField(""));
    }

    @Test
    void testEscapeCsvField_QuotesAndCommas() {
        assertEquals("\"Nguyen, Van A\"", CustomerExportServlet.escapeCsvField("Nguyen, Van A"));
        assertEquals("\"Name with \"\"Quotes\"\"\"", CustomerExportServlet.escapeCsvField("Name with \"Quotes\""));
    }
}
