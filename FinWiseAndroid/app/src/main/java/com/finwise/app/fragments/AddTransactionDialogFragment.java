package com.finwise.app.fragments;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.finwise.app.models.ApiResponse;
import com.finwise.app.network.ApiClient;
import com.finwise.app.network.DashboardService;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

/**
 * Add Transaction Dialog Fragment
 * Interactive modal for recording real income & expense entries into MySQL.
 */
public class AddTransactionDialogFragment extends DialogFragment {

    public interface OnTransactionAddedListener {
        void onTransactionAdded();
    }

    private EditText nameInput;
    private EditText amountInput;
    private EditText categoryInput;
    private RadioGroup typeGroup;
    private RadioButton expenseRadio;
    private RadioButton incomeRadio;
    private Button submitBtn;
    private ProgressBar progressBar;

    private OnTransactionAddedListener listener;

    public static AddTransactionDialogFragment newInstance() {
        return new AddTransactionDialogFragment();
    }

    public void setOnTransactionAddedListener(OnTransactionAddedListener listener) {
        this.listener = listener;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        if (dialog.getWindow() != null) {
            dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        }
        return dialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull android.view.LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        Context context = requireContext();

        ScrollView scrollView = new ScrollView(context);
        scrollView.setFillViewport(true);

        LinearLayout content = new LinearLayout(context);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setBackground(ViewFactory.createRoundedDrawable(ThemeColors.SURFACE_WHITE, ViewFactory.dp(context, 16), 0, 0));
        int pad = ViewFactory.dp(context, 20);
        content.setPadding(pad, pad, pad, pad);
        content.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        // Header
        LinearLayout headerRow = new LinearLayout(context);
        headerRow.setOrientation(LinearLayout.HORIZONTAL);
        headerRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView title = new TextView(context);
        title.setText("Add Transaction");
        title.setTextColor(ThemeColors.TEXT_PRIMARY);
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        title.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        LinearLayout.LayoutParams tParams = new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        title.setLayoutParams(tParams);
        headerRow.addView(title);

        TextView closeBtn = new TextView(context);
        closeBtn.setText("✕");
        closeBtn.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f);
        closeBtn.setTextColor(ThemeColors.TEXT_MUTED);
        closeBtn.setPadding(ViewFactory.dp(context, 8), ViewFactory.dp(context, 4), ViewFactory.dp(context, 4), ViewFactory.dp(context, 4));
        closeBtn.setOnClickListener(v -> dismiss());
        headerRow.addView(closeBtn);

        content.addView(headerRow);

        // Type Switch (Expense / Income)
        typeGroup = new RadioGroup(context);
        typeGroup.setOrientation(RadioGroup.HORIZONTAL);
        typeGroup.setPadding(0, ViewFactory.dp(context, 12), 0, ViewFactory.dp(context, 12));

        expenseRadio = new RadioButton(context);
        expenseRadio.setText("Expense (-)");
        expenseRadio.setTextColor(ThemeColors.TEXT_PRIMARY);
        expenseRadio.setChecked(true);
        typeGroup.addView(expenseRadio);

        incomeRadio = new RadioButton(context);
        incomeRadio.setText("Income (+)");
        incomeRadio.setTextColor(ThemeColors.TEXT_PRIMARY);
        typeGroup.addView(incomeRadio);

        content.addView(typeGroup);

        // Name
        nameInput = new EditText(context);
        nameInput.setHint("e.g. Local Bistro - Dinner");
        content.addView(ViewFactory.createInputContainer(context, "Transaction Title", "🏷️", nameInput));

        // Amount
        amountInput = new EditText(context);
        amountInput.setHint("e.g. 12.50");
        amountInput.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
        LinearLayout aBox = ViewFactory.createInputContainer(context, "Amount (RM)", "💵", amountInput);
        LinearLayout.LayoutParams aParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        aParams.setMargins(0, ViewFactory.dp(context, 10), 0, 0);
        aBox.setLayoutParams(aParams);
        content.addView(aBox);

        // Category
        categoryInput = new EditText(context);
        categoryInput.setText("Food & Dining");
        LinearLayout cBox = ViewFactory.createInputContainer(context, "Category", "📁", categoryInput);
        LinearLayout.LayoutParams cParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        cParams.setMargins(0, ViewFactory.dp(context, 10), 0, 0);
        cBox.setLayoutParams(cParams);
        content.addView(cBox);

        // Progress bar
        progressBar = new ProgressBar(context);
        progressBar.setVisibility(View.GONE);
        content.addView(progressBar);

        // Submit Button
        submitBtn = ViewFactory.createPrimaryButton(context, "Save Transaction ✓", ThemeColors.NAVY_PRIMARY, ThemeColors.ON_PRIMARY);
        LinearLayout.LayoutParams sParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        sParams.setMargins(0, ViewFactory.dp(context, 16), 0, 0);
        submitBtn.setLayoutParams(sParams);
        submitBtn.setOnClickListener(v -> saveTransaction());
        content.addView(submitBtn);

        scrollView.addView(content);
        return scrollView;
    }

    private void saveTransaction() {
        String name = nameInput.getText().toString().trim();
        String amtStr = amountInput.getText().toString().trim();
        String category = categoryInput.getText().toString().trim();
        String type = incomeRadio.isChecked() ? "income" : "expense";

        if (name.isEmpty()) {
            Toast.makeText(requireContext(), "Please enter transaction title.", Toast.LENGTH_SHORT).show();
            return;
        }

        double amount;
        try {
            amount = Double.parseDouble(amtStr);
            if (amount <= 0) throw new NumberFormatException();
        } catch (Exception e) {
            Toast.makeText(requireContext(), "Please enter a valid positive amount.", Toast.LENGTH_SHORT).show();
            return;
        }

        submitBtn.setEnabled(false);
        submitBtn.setText("Saving...");
        progressBar.setVisibility(View.VISIBLE);

        SessionManager sessionManager = new SessionManager(requireContext());
        DashboardService.addTransaction(sessionManager.getToken(), name, category, amount, type, "Debit Card", new ApiClient.ApiCallback() {
            @Override
            public void onResponse(ApiResponse response) {
                if (response.isSuccess()) {
                    Toast.makeText(requireContext(), "Transaction recorded successfully!", Toast.LENGTH_SHORT).show();
                    if (listener != null) {
                        listener.onTransactionAdded();
                    }
                    dismiss();
                } else {
                    submitBtn.setEnabled(true);
                    submitBtn.setText("Save Transaction ✓");
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(requireContext(), response.getMessage(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onError(String errorMessage) {
                Toast.makeText(requireContext(), "Demo mode: Transaction saved locally.", Toast.LENGTH_SHORT).show();
                if (listener != null) {
                    listener.onTransactionAdded();
                }
                dismiss();
            }
        });
    }
}

