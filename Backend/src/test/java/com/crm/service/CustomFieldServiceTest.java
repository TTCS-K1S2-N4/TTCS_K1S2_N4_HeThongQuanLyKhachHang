package com.crm.service;

import com.crm.dao.CustomFieldDefinitionDAO;
import com.crm.dao.CustomFieldValueDAO;
import com.crm.model.CustomFieldDefinition;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

public class CustomFieldServiceTest {

    private CustomFieldDefinitionDAO mockDefDAO;
    private CustomFieldValueDAO mockValueDAO;
    private CustomFieldService customFieldService;

    @BeforeEach
    public void setUp() {
        mockDefDAO = Mockito.mock(CustomFieldDefinitionDAO.class);
        mockValueDAO = Mockito.mock(CustomFieldValueDAO.class);
        customFieldService = new CustomFieldService(mockDefDAO, mockValueDAO);
    }

    @Test
    public void testValidateSubmittedCustomFields_WhenRequiredMissing_ShouldReturnError() {
        List<CustomFieldDefinition> defs = new ArrayList<>();
        CustomFieldDefinition def1 = new CustomFieldDefinition();
        def1.setFieldId(1);
        def1.setFieldLabel("Mức độ quan tâm");
        def1.setFieldType("SELECT");
        def1.setRequired(true);
        defs.add(def1);

        when(mockDefDAO.getDefinitions("CUSTOMER", "ACTIVE")).thenReturn(defs);

        Map<Integer, String> submitted = new HashMap<>(); // empty submitted values

        List<String> errors = customFieldService.validateSubmittedCustomFields("CUSTOMER", submitted);

        assertEquals(1, errors.size());
        assertTrue(errors.get(0).contains("là bắt buộc"));
    }

    @Test
    public void testValidateSubmittedCustomFields_WhenNumberInvalid_ShouldReturnError() {
        List<CustomFieldDefinition> defs = new ArrayList<>();
        CustomFieldDefinition def1 = new CustomFieldDefinition();
        def1.setFieldId(2);
        def1.setFieldLabel("Điểm tích lũy");
        def1.setFieldType("NUMBER");
        def1.setRequired(false);
        defs.add(def1);

        when(mockDefDAO.getDefinitions("CUSTOMER", "ACTIVE")).thenReturn(defs);

        Map<Integer, String> submitted = new HashMap<>();
        submitted.put(2, "abc_invalid_number");

        List<String> errors = customFieldService.validateSubmittedCustomFields("CUSTOMER", submitted);

        assertEquals(1, errors.size());
        assertTrue(errors.get(0).contains("phải là số hợp lệ"));
    }

    @Test
    public void testValidateSubmittedCustomFields_WhenValid_ShouldReturnEmptyErrors() {
        List<CustomFieldDefinition> defs = new ArrayList<>();
        CustomFieldDefinition def1 = new CustomFieldDefinition();
        def1.setFieldId(3);
        def1.setFieldLabel("Mức độ quan tâm");
        def1.setFieldType("SELECT");
        def1.setOptions("Thấp, Trung bình, Cao");
        def1.setRequired(true);
        defs.add(def1);

        when(mockDefDAO.getDefinitions("CUSTOMER", "ACTIVE")).thenReturn(defs);

        Map<Integer, String> submitted = new HashMap<>();
        submitted.put(3, "Cao");

        List<String> errors = customFieldService.validateSubmittedCustomFields("CUSTOMER", submitted);

        assertTrue(errors.isEmpty());
    }
}
