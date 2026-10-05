package com.crm.dto;

import com.crm.model.Contact;
import com.crm.model.ContactCompanyHistory;

import java.util.List;
import java.util.Map;

public class ContactResponse {
    private boolean success;
    private String message;
    private Map<String, String> errors;
    private Contact contact;
    private List<Contact> contacts;
    private List<ContactCompanyHistory> history;

    public ContactResponse() {
    }

    public static ContactResponse success(String message) {
        ContactResponse resp = new ContactResponse();
        resp.setSuccess(true);
        resp.setMessage(message);
        return resp;
    }

    public static ContactResponse error(String message, Map<String, String> errors) {
        ContactResponse resp = new ContactResponse();
        resp.setSuccess(false);
        resp.setMessage(message);
        resp.setErrors(errors);
        return resp;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Map<String, String> getErrors() {
        return errors;
    }

    public void setErrors(Map<String, String> errors) {
        this.errors = errors;
    }

    public Contact getContact() {
        return contact;
    }

    public void setContact(Contact contact) {
        this.contact = contact;
    }

    public List<Contact> getContacts() {
        return contacts;
    }

    public void setContacts(List<Contact> contacts) {
        this.contacts = contacts;
    }

    public List<ContactCompanyHistory> getHistory() {
        return history;
    }

    public void setHistory(List<ContactCompanyHistory> history) {
        this.history = history;
    }
}
