package com.crm.service;

import com.crm.dao.AccountDAO;
import com.crm.dto.AccountCreateRequest;
import com.crm.dto.AccountUpdateRequest;
import com.crm.model.Account;
import org.mindrot.jbcrypt.BCrypt;
import java.util.List;

public class AccountService {
    private final AccountDAO accountDAO = new AccountDAO();

    public boolean createAccount(AccountCreateRequest req) {
        if (accountDAO.isEmailExists(req.getEmail(), 0)) {
            return false;
        }
        String passwordHash = BCrypt.hashpw(req.getPassword(), BCrypt.gensalt(12));
        return accountDAO.createAccount(req.getEmail(), passwordHash, req.getFullName(), req.getPhone(), req.getTeamId());
    }

    public List<Account> getAccountList(String keyword, Integer teamId, String status, int page) {
        return accountDAO.getAccounts(keyword, teamId, status, page);
    }

    public int countTotalAccounts(String keyword, Integer teamId, String status) {
        return accountDAO.countAccounts(keyword, teamId, status);
    }

    public Account getAccountDetail(int accountId) {
        return accountDAO.getAccountById(accountId);
    }

    public boolean updateAccount(AccountUpdateRequest req) {
        return accountDAO.updateAccount(req.getAccountId(), req.getFullName(), req.getPhone(), req.getTeamId());
    }

    public int countOwnedAssets(int accountId) {
        return accountDAO.countOwnedRecords(accountId);
    }

    public boolean lockAndTransferData(int accountId, Integer receiverId, int adminId) {
        int ownedCount = accountDAO.countOwnedRecords(accountId);
        if (ownedCount > 0 && (receiverId == null || receiverId <= 0)) {
            return false;
        }
        return accountDAO.lockAccountAndTransfer(accountId, receiverId, adminId);
    }
}
