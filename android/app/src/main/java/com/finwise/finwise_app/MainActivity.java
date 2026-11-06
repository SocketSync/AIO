package com.finwise.finwise_app;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.regex.Pattern;

/** Simple native Android client for FinWise's PHP authentication API. */
public class MainActivity extends Activity {
    private static final int NAVY = Color.rgb(0, 35, 111);
    private static final int BG = Color.rgb(250,248,255), MUTED = Color.rgb(100,116,139);
    // Android emulator loopback to the development host. Change for a deployed API.
    private static final String API = "http://10.0.2.2:8080/php/api/";
    private static final Pattern EMAIL = Pattern.compile("^[A-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?(?:\\.[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)+$", Pattern.CASE_INSENSITIVE);
    private final ExecutorService io = Executors.newSingleThreadExecutor();
    private final Handler handler = new Handler(Looper.getMainLooper());
    private EditText emailField, passwordField;
    private String pendingEmail = "", signedInName = "";
    private int resendSeconds;
    private Runnable countdown;

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().setStatusBarColor(BG); getWindow().setNavigationBarColor(BG);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        showLogin();
    }
    private int dp(int x) { return (int)(x * getResources().getDisplayMetrics().density + .5f); }
    private LinearLayout column() { LinearLayout v=new LinearLayout(this);v.setOrientation(LinearLayout.VERTICAL);return v; }
    private TextView text(String s,int size,int color,boolean bold) {
        TextView t=new TextView(this);t.setText(s);t.setTextSize(size);t.setTextColor(color);
        if(bold)t.setTypeface(Typeface.DEFAULT,Typeface.BOLD);return t;
    }
    private EditText field(String hint,int inputType) {
        EditText e=new EditText(this);e.setSingleLine(true);e.setHint(hint);e.setInputType(inputType);e.setTextSize(16);
        e.setPadding(dp(14),dp(10),dp(14),dp(10));return e;
    }
    private Button button(String label,Runnable action) {
        Button b=new Button(this);b.setText(label);b.setAllCaps(false);b.setTextColor(Color.WHITE);b.setTextSize(16);
        b.setBackgroundTintList(android.content.res.ColorStateList.valueOf(NAVY));b.setOnClickListener(v->action.run());return b;
    }
    private void add(LinearLayout c,View v,int top) {
        LinearLayout.LayoutParams p=new LinearLayout.LayoutParams(-1,-2);p.topMargin=dp(top);c.addView(v,p);
    }
    private LinearLayout page(String title,String subtitle) {
        LinearLayout root=column();root.setBackgroundColor(BG);root.setPadding(dp(24),dp(24),dp(24),dp(24));
        ScrollView scroll=new ScrollView(this);scroll.setFillViewport(true);LinearLayout c=column();
        add(c,text("FinWise",28,NAVY,true),6);add(c,text(title,23,Color.rgb(15,23,42),true),28);add(c,text(subtitle,14,MUTED,false),5);
        scroll.addView(c);root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));setContentView(root);return c;
    }
    private TextView link(String label,Runnable action) {
        TextView t=text(label,14,NAVY,true);t.setPadding(0,dp(8),0,dp(8));t.setOnClickListener(v->action.run());return t;
    }
    private String value(EditText e){return e.getText().toString().trim();}
    private boolean validEmail(String e){return EMAIL.matcher(e).matches();}

    private void showLogin() {
        stopCountdown();LinearLayout c=page("Welcome back","Sign in to manage your finances.");
        add(c,text("Student Email",14,MUTED,true),26);emailField=field("name@example.com",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);add(c,emailField,4);
        add(c,text("Password",14,MUTED,true),16);passwordField=field("Password",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_PASSWORD);add(c,passwordField,4);
        TextView forgot=link("Forgot Password?",this::showForgotEmail);forgot.setGravity(Gravity.RIGHT);add(c,forgot,3);
        add(c,button("Log In",this::login),22);TextView register=link("New to FinWise?  Create account",this::showRegister);register.setGravity(Gravity.CENTER);add(c,register,14);
    }
    private void login() {
        String email=value(emailField),password=passwordField.getText().toString();
        if(email.isEmpty()){message("Enter Email Address");return;}
        if(!validEmail(email)){message("Invalid Format Email Address");return;}
        if(password.isEmpty()){message("Enter Password");return;}
        JSONObject b=json("email",email,"password",password);
        request("login.php",b,r->{if(r.optBoolean("success")){JSONObject u=r.optJSONObject("user");signedInName=u==null?"":u.optString("full_name","");showDashboard();}
            else if(r.optBoolean("require_verification")){pendingEmail=r.optString("email",email);showVerification(r.optInt("seconds_remaining",0));}
            else message(r.optString("message","Unable to sign in."));});
    }
    private void showRegister() {
        LinearLayout c=page("Create account","Register your FinWise account.");
        EditText name=field("Full Name",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_FLAG_CAP_WORDS);
        EditText email=field("Email Address",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
        EditText pass=field("Password (at least 8 characters)",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_PASSWORD);
        EditText confirm=field("Confirm Password",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_PASSWORD);
        add(c,name,24);add(c,email,12);add(c,pass,12);add(c,confirm,12);
        add(c,button("Register",()->{
            String n=value(name),em=value(email),p=pass.getText().toString(),cp=confirm.getText().toString();
            if(n.isEmpty()||em.isEmpty()||p.isEmpty()||cp.isEmpty()){message("Complete all fields.");return;}
            if(!validEmail(em)){message("Invalid Format Email Address");return;}
            if(p.length()<8){message("Password must be at least 8 characters.");return;}
            if(!p.equals(cp)){message("Passwords do not match.");return;}
            request("register.php",json("full_name",n,"email",em,"password",p,"confirm_password",cp),r->{
                if(r.optBoolean("success")){pendingEmail=em;showVerification(r.optInt("cooldown_seconds",60));}
                else message(r.optString("message","Registration failed."));});}),22);
        TextView back=link("Back to Login",this::showLogin);back.setGravity(Gravity.CENTER);add(c,back,10);
    }
    private void showVerification(int seconds) {
        stopCountdown();resendSeconds=Math.max(0,seconds);LinearLayout c=page("Verify your email","Enter the 6-digit code sent to "+pendingEmail+".");
        EditText code=field("6-digit code",InputType.TYPE_CLASS_NUMBER);add(c,code,24);
        add(c,button("Verify Email",()->{String otp=value(code);if(!otp.matches("\\d{6}")){message("Enter the 6-digit verification code.");return;}
            request("verify_email.php",json("email",pendingEmail,"otp",otp),r->{if(r.optBoolean("success")){showLogin();message("Email verified. Please log in.");}else message(r.optString("message","Incorrect verification code."));});}),14);
        TextView resend=text("",14,MUTED,false);add(c,resend,8);updateCountdown(resend);
        TextView back=link("Back to Login",this::showLogin);back.setGravity(Gravity.CENTER);add(c,back,12);
    }
    private void updateCountdown(TextView v) {
        if(resendSeconds<=0){v.setText("Resend code");v.setTextColor(NAVY);v.setOnClickListener(w->request("resend_otp.php",json("email",pendingEmail),r->{
            if(r.optBoolean("success")){resendSeconds=r.optInt("cooldown_seconds",60);updateCountdown(v);}
            else{resendSeconds=r.optInt("seconds_remaining",0);updateCountdown(v);message(r.optString("message","Could not resend code."));}}));return;}
        v.setText("Resend available in "+resendSeconds+" seconds");v.setOnClickListener(null);
        countdown=()->{resendSeconds--;if(v.isAttachedToWindow())updateCountdown(v);};handler.postDelayed(countdown,1000);
    }
    private void stopCountdown(){if(countdown!=null)handler.removeCallbacks(countdown);countdown=null;}
    private void showForgotEmail() {
        LinearLayout c=page("Reset password","Enter your registered email. We will send a reset link.");
        EditText email=field("Email Address",InputType.TYPE_CLASS_TEXT|InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);add(c,email,24);
        add(c,button("Send reset link",()->{String em=value(email);if(em.isEmpty()){message("Enter Email Address");return;}if(!validEmail(em)){message("Invalid Format Email Address");return;}
            request("forgot_password.php",json("email",em,"action","request"),r->{if(r.optBoolean("success"))message("A password reset link was sent to your email. Open it to choose a new password.");else message(r.optString("message","Could not send reset email."));});}),16);
        TextView back=link("Back to Login",this::showLogin);back.setGravity(Gravity.CENTER);add(c,back,12);
    }
    private View card(String title,String value) {
        LinearLayout box=column();box.setPadding(dp(16),dp(14),dp(16),dp(14));box.setBackgroundColor(Color.WHITE);
        add(box,text(title,12,MUTED,true),0);add(box,text(value,17,NAVY,true),6);return box;
    }
    private void showDashboard() {
        LinearLayout root=column();root.setBackgroundColor(BG);ScrollView scroll=new ScrollView(this);LinearLayout c=column();c.setPadding(dp(20),dp(18),dp(20),dp(20));
        LinearLayout header=new LinearLayout(this);header.setGravity(Gravity.CENTER_VERTICAL);header.addView(text("FinWise",24,NAVY,true),new LinearLayout.LayoutParams(0,-2,1));header.addView(link("Log out",this::showLogin));c.addView(header);
        add(c,card("AI COPILOT","Your finances at a glance. Keep tracking spending to get smarter insights."),14);
        add(c,text("Welcome, "+(signedInName.isEmpty()?"there":signedInName),20,Color.rgb(15,23,42),true),18);
        add(c,card("TOTAL AVAILABLE BALANCE","RM 3,420.50"),14);
        LinearLayout pair=new LinearLayout(this);pair.addView(card("INCOME","RM 2,800.00"),new LinearLayout.LayoutParams(0,-2,1));pair.addView(card("EXPENSES","RM 1,485.20"),new LinearLayout.LayoutParams(0,-2,1));add(c,pair,10);
        add(c,card("SMART SPEND ALERT","You are on track with your monthly spending."),12);
        add(c,card("7-DAY OUTFLOW TREND","Mon   Tue   Wed   Thu   Fri   Sat   Sun\n ▂      ▄      ▃      ▅      ▂      ▆      ▃"),12);
        add(c,text("Recent Transactions",18,Color.rgb(15,23,42),true),18);
        add(c,card("Campus Cafe","Today · Food                                      − RM 12.50"),8);
        add(c,card("Monthly Allowance","Yesterday · Income                         + RM 800.00"),8);
        add(c,card("Bus Pass","Yesterday · Transport                   − RM 30.00"),8);
        scroll.addView(c);root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));
        LinearLayout nav=new LinearLayout(this);nav.setGravity(Gravity.CENTER);nav.setBackgroundColor(Color.WHITE);
        for(String label:new String[]{"Home","Budgets","+ Add","Insights","Simulator"}){TextView t=text(label,12,NAVY,true);t.setGravity(Gravity.CENTER);t.setPadding(dp(4),dp(14),dp(4),dp(14));nav.addView(t,new LinearLayout.LayoutParams(0,-2,1));}
        root.addView(nav);setContentView(root);
    }
    private JSONObject json(String... kv){JSONObject o=new JSONObject();try{for(int i=0;i+1<kv.length;i+=2)o.put(kv[i],kv[i+1]);}catch(Exception ignored){}return o;}
    private interface Result{void done(JSONObject value);}
    private void request(String endpoint,JSONObject body,Result callback){io.execute(()->{
        JSONObject parsed;HttpURLConnection conn=null;try{
            conn=(HttpURLConnection)new URL(API+endpoint).openConnection();conn.setRequestMethod("POST");conn.setConnectTimeout(10000);conn.setReadTimeout(15000);conn.setDoOutput(true);conn.setRequestProperty("Content-Type","application/json; charset=UTF-8");
            try(OutputStream out=conn.getOutputStream()){out.write(body.toString().getBytes(StandardCharsets.UTF_8));}
            InputStream in=conn.getResponseCode()<400?conn.getInputStream():conn.getErrorStream();ByteArrayOutputStream bytes=new ByteArrayOutputStream();byte[] buf=new byte[2048];int n;while(in!=null&&(n=in.read(buf))!=-1)bytes.write(buf,0,n);
            parsed=new JSONObject(new String(bytes.toByteArray(),StandardCharsets.UTF_8));
        }catch(Exception ex){parsed=json("success","false","message","Network error: "+ex.getMessage());}
        finally{if(conn!=null)conn.disconnect();}JSONObject response=parsed;handler.post(()->callback.done(response));});
    }
    private void message(String message){new AlertDialog.Builder(this).setMessage(message).setPositiveButton("OK",null).show();}
    @Override protected void onDestroy(){stopCountdown();io.shutdownNow();super.onDestroy();}
}
