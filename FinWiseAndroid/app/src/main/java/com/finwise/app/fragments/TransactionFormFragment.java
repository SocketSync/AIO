package com.finwise.app.fragments;

import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.finwise.app.models.ApiResponse;
import com.finwise.app.models.Transaction;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.DashboardService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/** Add/edit transaction page. */
public class TransactionFormFragment extends Fragment {
    private static final String ARG_ID = "id";
    private static final String ARG_DESCRIPTION = "description";
    private static final String ARG_CATEGORY = "category";
    private static final String ARG_AMOUNT = "amount";
    private static final String ARG_TYPE = "type";
    private static final String ARG_DATE = "date";

    private EditText descriptionInput;
    private EditText amountInput;
    private EditText dateInput;
    private Spinner categorySpinner;
    private RadioGroup typeGroup;
    private Button saveButton;
    private final String[] incomeCategories = {"Allowance", "Salary", "Scholarship", "Other Income"};
    private final String[] expenseCategories = {"Food", "Transport", "Shopping", "Education", "Entertainment", "Bills", "Other Expenses"};

    public static TransactionFormFragment newInstance(@Nullable Transaction transaction) {
        TransactionFormFragment fragment = new TransactionFormFragment();
        if (transaction != null) {
            Bundle args = new Bundle();
            args.putInt(ARG_ID, transaction.getId());
            args.putString(ARG_DESCRIPTION, transaction.getTransactionName());
            args.putString(ARG_CATEGORY, transaction.getCategory());
            args.putDouble(ARG_AMOUNT, transaction.getAmount());
            args.putString(ARG_TYPE, transaction.getTransactionType());
            args.putString(ARG_DATE, transaction.getTransactionDate());
            fragment.setArguments(args);
        }
        return fragment;
    }

    @Override public View onCreateView(android.view.LayoutInflater inflater, ViewGroup container, Bundle state) {
        LinearLayout root = new LinearLayout(requireContext());
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(ThemeColors.BACKGROUND);
        ScrollView scroll = new ScrollView(requireContext());
        LinearLayout content = new LinearLayout(requireContext());
        content.setOrientation(LinearLayout.VERTICAL);
        int pad = ViewFactory.dp(requireContext(), 16);
        content.setPadding(pad, pad, pad, ViewFactory.dp(requireContext(), 90));

        typeGroup = new RadioGroup(requireContext());
        typeGroup.setOrientation(RadioGroup.HORIZONTAL);
        RadioButton income = new RadioButton(requireContext());
        income.setText("Income");
        RadioButton expense = new RadioButton(requireContext());
        expense.setText("Expense");
        typeGroup.addView(income);
        typeGroup.addView(expense);
        content.addView(typeGroup);

        descriptionInput = input("Description");
        content.addView(ViewFactory.createInputContainer(requireContext(), "Description", "", descriptionInput));
        amountInput = input("0.00");
        amountInput.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
        content.addView(margin(ViewFactory.createInputContainer(requireContext(), "Amount (RM)", "", amountInput), 12));
        categorySpinner = new Spinner(requireContext());
        content.addView(margin(categorySpinner, 12));
        dateInput = input("YYYY-MM-DD");
        dateInput.setInputType(InputType.TYPE_CLASS_DATETIME | InputType.TYPE_DATETIME_VARIATION_DATE);
        content.addView(margin(ViewFactory.createInputContainer(requireContext(), "Date", "", dateInput), 12));

        saveButton = ViewFactory.createPrimaryButton(requireContext(), "Save Transaction", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        content.addView(margin(saveButton, 20));
        saveButton.setOnClickListener(v -> save());
        scroll.addView(content);
        root.addView(scroll, new LinearLayout.LayoutParams(-1, -1));

        income.setOnClickListener(v -> updateCategories(incomeCategories, null));
        expense.setOnClickListener(v -> updateCategories(expenseCategories, null));
        Bundle args = getArguments();
        boolean editing = args != null && args.getInt(ARG_ID, 0) > 0;
        String type = args != null ? args.getString(ARG_TYPE, "expense") : "expense";
        if ("income".equals(type)) income.setChecked(true); else expense.setChecked(true);
        updateCategories("income".equals(type) ? incomeCategories : expenseCategories, args == null ? null : args.getString(ARG_CATEGORY));
        dateInput.setText(args != null ? args.getString(ARG_DATE, today()) : today());
        if (args != null) {
            descriptionInput.setText(args.getString(ARG_DESCRIPTION, ""));
            if (args.containsKey(ARG_AMOUNT)) amountInput.setText(String.format(Locale.US, "%.2f", args.getDouble(ARG_AMOUNT)));
        }
        saveButton.setText(editing ? "Update Transaction" : "Save Transaction");
        return root;
    }

    private EditText input(String hint) {
        EditText input = new EditText(requireContext());
        input.setHint(hint);
        input.setSingleLine(true);
        return input;
    }

    private View margin(View view, int top) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(-1, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.setMargins(0, ViewFactory.dp(requireContext(), top), 0, 0);
        view.setLayoutParams(params);
        return view;
    }

    private void updateCategories(String[] categories, String selected) {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(), android.R.layout.simple_spinner_item, categories);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        categorySpinner.setAdapter(adapter);
        if (selected != null) {
            for (int i = 0; i < categories.length; i++) if (categories[i].equals(selected)) categorySpinner.setSelection(i);
        }
    }

    private void save() {
        String description = descriptionInput.getText().toString().trim();
        String amountText = amountInput.getText().toString().trim();
        String date = dateInput.getText().toString().trim();
        if (description.isEmpty() || amountText.isEmpty() || date.isEmpty()) {
            Toast.makeText(requireContext(), "Please complete all fields.", Toast.LENGTH_SHORT).show();
            return;
        }
        double amount;
        try { amount = Double.parseDouble(amountText); } catch (NumberFormatException e) {
            Toast.makeText(requireContext(), "Enter a valid amount.", Toast.LENGTH_SHORT).show(); return;
        }
        if (amount <= 0) { Toast.makeText(requireContext(), "Amount must be greater than zero.", Toast.LENGTH_SHORT).show(); return; }
        RadioButton selectedType = typeGroup.findViewById(typeGroup.getCheckedRadioButtonId());
        if (selectedType == null) {
            Toast.makeText(requireContext(), "Choose Income or Expense.", Toast.LENGTH_SHORT).show();
            return;
        }
        String type = "Income".contentEquals(selectedType.getText()) ? "income" : "expense";
        int id = getArguments() == null ? 0 : getArguments().getInt(ARG_ID, 0);
        saveButton.setEnabled(false);
        DashboardService.saveTransaction(new SessionManager(requireContext()).getToken(), id, description,
                String.valueOf(categorySpinner.getSelectedItem()), amount, type, date, new ApiClient.ApiCallback() {
                    @Override public void onResponse(ApiResponse response) {
                        saveButton.setEnabled(true);
                        if (response.isSuccess()) {
                            Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_SHORT).show();
                            if (getActivity() instanceof com.finwise.app.activities.MainActivity) {
                                ((com.finwise.app.activities.MainActivity) getActivity()).showHome();
                            }
                        } else Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_LONG).show();
                    }
                    @Override public void onError(String errorMessage) { saveButton.setEnabled(true); Toast.makeText(requireContext(), errorMessage, Toast.LENGTH_LONG).show(); }
                });
    }

    private String today() { return new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(new Date()); }
}
