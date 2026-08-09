# **Business Understanding**

## 1. Business Problem (ปัญหาทางธุรกิจ)
บริษัทโทรคมนาคมแห่งหนึ่งกำลังเผชิญกับปัญหา **Customer Churn (การยกเลิกบริการของลูกค้า)** ที่สูงถึง 26.54% ซึ่งส่งผลกระทบโดยตรงต่อรายได้ของบริษัท เป้าหมายของโปรเจกต์นี้คือการวิเคราะห์หาสาเหตุที่ทำให้ลูกค้ายกเลิกบริการ และสร้างโมเดล Machine Learning เพื่อพยากรณ์ความน่าจะเป็นที่ลูกค้าแต่ละรายจะยกเลิกบริการในอนาคต

## 2. SQL EDA & Key Insights (สรุปผลการวิเคราะห์เบื้องต้น)
ก่อนที่จะเริ่มสร้างโมเดลใน Notebook นี้ ได้มีการทำ Exploratory Data Analysis (EDA) ผ่านฐานข้อมูล PostgreSQL เพื่อเจาะลึกพฤติกรรมลูกค้า และได้ข้อค้นพบที่สำคัญ (The Perfect Storm) ดังนี้:

* **Contract & Tenure:** ลูกค้าที่ใช้สัญญาแบบ Month-to-month ในช่วง 1 ปีแรก มีอัตราการยกเลิกสูงที่สุด
* **Product & Value-Added:** ลูกค้า Fiber Optic ที่ **"ไม่รับ"** บริการเสริม (เช่น Tech Support, Streaming TV) ย้ายค่ายง่ายกว่าคนที่ซื้อแพ็กเกจพ่วง (ขาด Lock-in Effect)
* **Payment Method:** ลูกค้าที่จ่ายบิลแบบแมนนวล (Electronic check) มีอัตรา Churn สูงถึง 45.29% เพราะมีจุดเตือนสติให้ทบทวนค่าใช้จ่ายทุกเดือน
* **Demographics:** คนโสดที่ไม่มีภาระครอบครัวตัดสินใจย้ายค่ายได้ง่ายที่สุด

## 3. Project Objective (เป้าหมายของ Notebook นี้)
1. **Data Extraction:** ดึงข้อมูลที่ผ่านการทำความสะอาด (Cleaned Data) จาก Database
2. **Data Preprocessing:** เตรียมข้อมูล Feature Engineering ให้พร้อมสำหรับอัลกอริทึม
3. **Machine Learning Modeling:** เทรนโมเดล (เช่น Random Forest / XGBoost) เพื่อหารูปแบบความเสี่ยง
4. **Evaluation & Recommendations:** ประเมินความแม่นยำของโมเดล และสรุปกลยุทธ์เพื่อรักษาฐานลูกค้า
---
