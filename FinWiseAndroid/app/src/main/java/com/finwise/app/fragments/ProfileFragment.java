package com.finwise.app.fragments;

import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.fragment.app.Fragment;

import com.finwise.app.models.User;
import com.finwise.app.ui.ThemeColors;
import com.finwise.app.ui.ViewFactory;
import com.finwise.app.utils.SessionManager;

/** Basic authenticated user profile page. */
public class ProfileFragment extends Fragment {
    @Override public View onCreateView(android.view.LayoutInflater inflater, android.view.ViewGroup container, android.os.Bundle state) {
        LinearLayout root = new LinearLayout(requireContext());
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER_HORIZONTAL);
        root.setPadding(ViewFactory.dp(requireContext(), 24), ViewFactory.dp(requireContext(), 32), ViewFactory.dp(requireContext(), 24), ViewFactory.dp(requireContext(), 24));
        User user = new SessionManager(requireContext()).getUser();
        TextView title = new TextView(requireContext()); title.setText("Profile"); title.setTextSize(24f); title.setTextColor(ThemeColors.TEXT_PRIMARY); root.addView(title);
        TextView details = new TextView(requireContext()); details.setText((user == null ? "" : user.getFullName()) + "\n" + (user == null ? "" : user.getEmail())); details.setTextSize(16f); details.setTextColor(ThemeColors.TEXT_MUTED); details.setGravity(Gravity.CENTER); details.setPadding(0, 16, 0, 24); root.addView(details);
        Button logout = ViewFactory.createSecondaryButton(requireContext(), "Log Out", ThemeColors.SURFACE_HIGH, 0xFFB42318, 0);
        logout.setOnClickListener(v -> { if (getActivity() instanceof com.finwise.app.activities.MainActivity) ((com.finwise.app.activities.MainActivity) getActivity()).logoutFromProfile(); });
        root.addView(logout);
        return root;
    }
}
