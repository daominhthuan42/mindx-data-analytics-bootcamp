import cv2

# Đọc ảnh
img = cv2.imread("C:/00_DATA/02_KHOA_HOC_MINDX/01_MODULE_2/BUOI_6/HR_Attrition_template-2.png")

# Resize ảnh theo kích thước mới (width, height)
resized_img = cv2.resize(img, (1280, 720), interpolation=cv2.INTER_AREA)

# Lưu ảnh mới
cv2.imwrite("C:/00_DATA/02_KHOA_HOC_MINDX/01_MODULE_2/BUOI_6/HR_Attrition_template_2_updated.png", resized_img)
