import streamlit as st
import pandas as pd
import joblib
import os

# 1. การตั้งค่าหน้าเพจ
st.set_page_config(
    page_title="Customer Churn Prediction",
    page_icon="📉",
    layout="centered"
)

# 2. โหลดโมเดลพร้อมเพิ่ม Error Handling
@st.cache_resource
def load_artifacts():
    try:
        model = joblib.load('churn_model.pkl')
        feature_columns = joblib.load('feature_columns.pkl')
        threshold = joblib.load('threshold.pkl')
        return model, feature_columns, threshold
    except FileNotFoundError:
        return None, None, None

model, feature_columns, threshold = load_artifacts()

# ตรวจสอบว่ามีไฟล์โมเดลครบหรือไม่
if model is None:
    st.error("⚠️ ไม่พบไฟล์โมเดลที่จำเป็น กรุณาตรวจสอบว่ามีไฟล์ 'churn_model.pkl', 'feature_columns.pkl', และ 'threshold.pkl' ในโฟลเดอร์เดียวกัน")
    st.stop()

# 3. ส่วนหัวของแอป
st.title("📉 Customer Churn Prediction")
st.markdown("ระบบประเมินและทำนายความเสี่ยงการยกเลิกบริการของลูกค้า")
st.divider()

# 4. ฟอร์มรับข้อมูล
with st.form("churn_form"):
    
    # --- ส่วนที่ 1: ข้อมูลประชากรศาสตร์ ---
    st.subheader("👤 ข้อมูลส่วนตัวลูกค้า (Customer Profile)")
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        gender = st.selectbox("Gender", ["Male", "Female"])
    with col2:
        senior_input = st.selectbox("Senior Citizen", ["No", "Yes"])
    with col3:
        partner = st.selectbox("Partner", ["Yes", "No"])
    with col4:
        dependents = st.selectbox("Dependents", ["Yes", "No"])

    st.markdown("<br>", unsafe_allow_html=True)
    
    # --- ส่วนที่ 2: ข้อมูลบริการและสัญญา ---
    st.subheader("📦 ข้อมูลบริการและการชำระเงิน (Services & Billing)")
    col5, col6 = st.columns(2)
    with col5:
        internetservice = st.selectbox("Internet Service", ["DSL", "Fiber optic", "No"])
        contract = st.selectbox("Contract", ["Month-to-month", "One year", "Two year"])
        paymentmethod = st.selectbox("Payment Method", [
            "Electronic check", "Mailed check",
            "Bank transfer (automatic)", "Credit card (automatic)"
        ])
    with col6:
        tenure = st.slider("Tenure (อายุการใช้งาน - เดือน)", min_value=0, max_value=72, value=12)
        monthlycharges = st.number_input("Monthly Charges (ค่าบริการรายเดือน - $)", min_value=0.0, max_value=150.0, value=70.0, step=0.5)

    st.markdown("<br>", unsafe_allow_html=True)
    
    # ปุ่มกด Submit
    submitted = st.form_submit_button("🔍 ประเมินความเสี่ยง (Predict Churn Risk)", use_container_width=True)

# 5. การประมวลผลและแสดงผลลัพธ์
if submitted:
    # แปลงค่า Senior Citizen กลับเป็น 0 หรือ 1 สำหรับโมเดล
    senior_val = 1 if senior_input == "Yes" else 0

    # สร้าง DataFrame จากข้อมูลที่กรอก
    input_df = pd.DataFrame([{
        'seniorcitizen': senior_val, 
        'tenure': tenure,
        'monthlycharges': monthlycharges, 
        'gender': gender,
        'partner': partner, 
        'dependents': dependents,
        'internetservice': internetservice, 
        'contract': contract,
        'paymentmethod': paymentmethod
    }])
    
    # แปลงข้อมูลตาม Feature Columns ที่บันทึกไว้
    input_encoded = pd.get_dummies(input_df)
    input_final = input_encoded.reindex(columns=feature_columns, fill_value=0)

    # ทำนายผล
    proba = model.predict_proba(input_final)[:, 1][0]
    is_churn = proba >= threshold

    # แสดงผลลัพธ์
    st.divider()
    st.subheader("📊 ผลการประเมิน (Result)")

    # แบ่ง Layout สำหรับโชว์ผลลัพธ์
    res_col1, res_col2 = st.columns([1, 1])
    
    with res_col1:
        st.metric(label="โอกาสในการยกเลิกบริการ (Churn Probability)", value=f"{proba:.1%}")
        # แถบแสดงความเสี่ยง (Progress bar)
        st.progress(min(proba, 1.0))
        
    with res_col2:
        if is_churn:
            st.error("#### ⚠️ มีความเสี่ยงสูงที่จะยกเลิกบริการ (Churn)")
            st.write("แนะนำให้เสนอโปรโมชันหรือติดต่อดูแลลูกค้าเป็นพิเศษ")
        else:
            st.success("#### ✅ มีแนวโน้มใช้งานต่อ (Not Churn)")
            st.write("ลูกค้าอยู่ในสถานะปกติ")

    # ซ่อนรายละเอียด Threshold ไว้เพื่อไม่ให้หน้าจอดูรก
    with st.expander("ℹ️ รายละเอียดเชิงเทคนิค (Technical Details)"):
        st.caption(f"**Decision Threshold:** `{threshold:.3f}` (ตั้งค่าสำหรับ ~80% Recall)")
        st.caption("ระบบจะทำนายว่าเป็น Churn เมื่อความน่าจะเป็นมีค่ามากกว่าหรือเท่ากับ Threshold")