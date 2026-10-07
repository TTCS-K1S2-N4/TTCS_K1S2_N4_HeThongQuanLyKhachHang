package com.crm.service;

import com.crm.dao.CategoryDAO;
import com.crm.model.Category;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class CategoryServiceTest {

    private CategoryDAO mockCategoryDAO;
    private CategoryService categoryService;

    @BeforeEach
    public void setUp() {
        mockCategoryDAO = Mockito.mock(CategoryDAO.class);
        categoryService = new CategoryService(mockCategoryDAO);
    }

    @Test
    public void testDeleteCategory_WhenReferenced_ShouldRejectWithErrorMessage() throws SQLException {
        Category cat = new Category();
        cat.setCategoryId(10);
        cat.setCategoryType("INDUSTRY");
        cat.setCategoryName("Công nghệ");

        when(mockCategoryDAO.findById(10)).thenReturn(cat);
        when(mockCategoryDAO.countUsage("INDUSTRY", "Công nghệ")).thenReturn(3);

        java.util.List<String> errors = new java.util.ArrayList<>();
        boolean ok = categoryService.processCategoryUpdate(Category.Action.DELETE, cat, errors);

        assertFalse(ok);
        assertFalse(errors.isEmpty());
        assertTrue(errors.get(0).contains("đang được sử dụng"));
        verify(mockCategoryDAO, never()).delete(10);
    }

    @Test
    public void testDeleteCategory_WhenNotReferenced_ShouldSucceed() throws SQLException {
        Category cat = new Category();
        cat.setCategoryId(11);
        cat.setCategoryType("INDUSTRY");
        cat.setCategoryName("Test Unused Industry");

        when(mockCategoryDAO.findById(11)).thenReturn(cat);
        when(mockCategoryDAO.countUsage("INDUSTRY", "Test Unused Industry")).thenReturn(0);
        when(mockCategoryDAO.delete(11)).thenReturn(true);

        java.util.List<String> errors = new java.util.ArrayList<>();
        boolean ok = categoryService.processCategoryUpdate(Category.Action.DELETE, cat, errors);

        assertTrue(ok);
        assertTrue(errors.isEmpty());
        verify(mockCategoryDAO, times(1)).delete(11);
    }

    @Test
    public void testDeactivateCategory_WhenReferenced_ShouldReject() throws SQLException {
        Category cat = new Category();
        cat.setCategoryId(12);
        cat.setCategoryType("COMPANY_SIZE");
        cat.setCategoryName("Lớn");

        when(mockCategoryDAO.findById(12)).thenReturn(cat);
        when(mockCategoryDAO.countUsage("COMPANY_SIZE", "Lớn")).thenReturn(1);

        java.util.List<String> errors = new java.util.ArrayList<>();
        boolean ok = categoryService.processCategoryUpdate(Category.Action.DEACTIVATE, cat, errors);

        assertFalse(ok);
        assertFalse(errors.isEmpty());
        assertTrue(errors.get(0).contains("đang được sử dụng"));
        verify(mockCategoryDAO, never()).updateStatus(12, "INACTIVE");
    }
}

