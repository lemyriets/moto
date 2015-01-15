;; [[file:hh.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы
(in-package #:moto)

(define-iface-add-del-entity all-profiles "/profiles"
  "Поисковые профили"
  "Новый профиль"
  "Когда соискатель пользуется профильным сайтом он использует
   поисковые запросы, на основании которых мы можем формировать,
   гм... назовем это =поисковыми профилями=. Поисковый профиль - это
   запрос пользователя, плюс набор связанных с ним вакансий"
   #'all-profile "profile"
  (name)
  (frm
   (tbl
    (list
     (row "Название" (fld "name"))
     (row "Запрос" (fld "search"))
     (row "" %new%))))
  (:new (act-btn "NEW" "" "Создать")
        (progn
          (make-profile :name (getf p :name)
                        :user-id 1
                        :search-query (getf p :search)
                        :ts-create (get-universal-time)
                        :ts-last (get-universal-time))
          "Профиль создан"))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn
          (del-profile (getf p :data)))))

(in-package #:moto)

(defun vacancy-table (raw)
  (let ((vacs (sort (remove-if #'(lambda (x)
                                   (equal 0 (salary x)))
                               raw)
                    #'(lambda (a b)
                        (> (salary a) (salary b))))))
    (format nil "<h2>Вакансий: ~A</h2>~%~A" (length vacs)
            (tbl
             (with-collection (vac vacs)
               (tr
                (td
                 (state vac))
                (td
                 (format nil "<div style=\"background-color:green\">~A</div>"
                         (input "radio" :name (format nil "R~A" (id vac)) :value "y"
                                :other (if (string= ":INTERESTED" (state vac)) "checked=\"checked\"" ""))))
                (td
                 (format nil "<div style=\"background-color:red\">~A</div>"
                         (input "radio" :name (format nil "R~A" (id vac)) :value "n"
                                :other (if (string= ":NOT_INTERESTED" (state vac)) "checked=\"checked\"" ""))))
                (td (format nil "<a href=\"/vacancy/~A\">~A</a>" (id vac) (name vac)))
                (td (salary-text vac))
                (td (currency vac))))
             :border 1))))

(define-page profile "/profile/:userid"
  (let* ((i (parse-integer userid))
         (page-id (parse-integer userid))
         (u (get-profile i))
         (vacs (sort (remove-if #'(lambda (x)
                                    (equal 0 (salary x)))
                                (find-vacancy :profile-id page-id))
                     #'(lambda (a b)
                         (> (salary a) (salary b))))))
    (if (null u)
        "Нет такого профиля"
        (format nil "~{~A~}"
                (list
                 "<script>
                         function test (param) {
                            $.post(
                               \"/profile/1\",
                               {act: param},
                               function(data) {
                                  $(\"#dvtest\").html(data);
                               }
                           );
                         };
                  </script>"
                 (format nil "<h1>Страница поискового профиля ~A</h1>" (id u))
                 (format nil "<h2>Данные поискового профиля ~A</h2>" (name u))
                 (frm
                  (tbl
                   (with-element (u u)
                     (row "Имя профиля" (fld "name" (name u)))
                     (row "Запрос" (fld "search" (search-query u)))
                     (row (hid "profile_id" (id u)) %change%))
                   :border 1))
                 (tbl
                  (tr
                   (td %show-all%)
                   (td %show-interests%)
                   (td %show-not-interests%)
                   (td %show-other%)))
                 (frm %proceess-interests%)
                 (frm
                  (list
                   "<br /><br />"
                   %clarify%
                   "<div id=\"dvtest\">dvtest</div>"))))))
  (:change  (act-btn "CHANGE" "" "Изменить")
            (id (upd-profile (get-profile (parse-integer userid))
                             (list :name (getf p :name) :search-query (getf p :query)))))
  (:clarify (act-btn "CLARIFY" "" "Уточнить")
            (loop :for key :in (cddddr p) :by #'cddr :collect
               (let* ((val (getf p key))
                      (id  (parse-integer (subseq (symbol-name key) 1)))
                      (vac (get-vacancy id)))
                 (list id
                       (cond ((string= "y" val)
                              (unless (string= ":INTERESTED" (state vac))
                                (takt vac :interested)))
                             ((string= "n" val)
                              (unless (string= ":NOT_INTERESTED" (state vac))
                                (takt vac :not_interested)))
                             (t "err param"))))))
  (:show-all (format nil "<input type=\"button\" onclick=\"test('SHOW-ALL');\" value=\"все\">")
             (error 'ajax :output (vacancy-table (find-vacancy :profile-id 1))))
  (:show-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-INTERESTS');\" value=\"интересные\">")
                   (error 'ajax :output (vacancy-table (find-vacancy :state ":INTERESTED" :profile-id 1))))
  (:show-not-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-NOT-INTERESTS');\" value=\"неинтересные\">")
                       (error 'ajax :output (vacancy-table (find-vacancy :state ":NOT_INTERESTED" :profile-id 1))))
  (:show-other (format nil "<input type=\"button\" onclick=\"test('SHOW-OTHER');\" value=\"остальные\">")
               (error 'ajax :output (vacancy-table (remove-if #'(lambda (x)
                                                                  (or (string= ":NOT_INTERESTED" (state x) )
                                                                      (string= ":INTERESTED" (state x))))
                                                              (find-vacancy :profile-id 1)))))
  (:proceess-interests (act-btn "PROCEESS-INTERESTS" "" "Собрать данные интересных вакансий")
                       "TODO"))

;; (profile-id (car (all-vacancy)))

;; (mapcar #'(lambda (x)
;;             (salary x))
;;         (find-vacancy :profile-id 1))

;; (car
;;  (remove-if #'(lambda (x)
;;                 (null (getf x :salary)))
;;             *teasers*))

;; (currency
;;  (car
;;   (remove-if #'(lambda (x)
;;                  (equal (salary x) 0))
;;              (all-vacancy))))

(in-package #:moto)

(restas:define-route hh-main ("/hh")
  (with-wrapper
      "<h1>Главная страница HH</h1>"
    ))
(defparameter *slideshows* (make-hash-table :test 'equalp))

(defun add-slideshow (slideshow-name image-folder)
  (setf (gethash slideshow-name *slideshows*)
        (mapcar (lambda (pathname)
                  (url-encode (format nil "~a.~a"
                                      (pathname-name pathname)
                                      (pathname-type pathname))))
                (list-directory image-folder))))

(add-slideshow "img" "/home/rigidus/repo/moto/img/")
(add-slideshow "pic" "/home/rigidus/repo/moto/pic/")

(alexandria:hash-table-plist *slideshows*)

(defmacro/ps slideshow-image-uri (slideshow-name image-file)
  `(concatenate 'string ,slideshow-name "/" ,image-file))

(restas:define-route y ("y")
  (ps
    (define-symbol-macro fragment-identifier (@ window location hash))
    (defun show-image-number (image-index)
      (let ((image-name (aref *images* (setf *current-image-index* image-index))))
        (setf (chain document (get-element-by-id "slideshow-img-object") src)
              (slideshow-image-uri *slideshow-name* image-name)
              fragment-identifier
              image-name)))
    (defun previous-image ()
      (when (> *current-image-index* 0)
        (show-image-number (1- *current-image-index*))))
    (defun next-image ()
      (when (< *current-image-index* (1- (getprop *images* 'length)))
        (show-image-number (1+ *current-image-index*))))
    ;; this gives bookmarkability using fragment identifiers
    (setf (getprop window 'onload)
          (lambda ()
            (when fragment-identifier
              (let ((image-name (chain fragment-identifier (slice 1))))
                (dotimes (i (length *images*))
                  (when (string= image-name (aref *images* i))
                    (show-image-number i)))))))))

(defun slideshow-handler (slideshow-name)
  (let* ((images (gethash slideshow-name *slideshows*))
         (current-image-index (or (position (get-parameter "image") images :test #'equalp)
                                  0))
         (previous-image-index (max 0 (1- current-image-index)))
         (next-image-index (min (1- (length images)) (1+ current-image-index))))
    (with-html-output-to-string (s)
      (:html
       (:head
        (:title "Parenscript slideshow")
        (:script :type "text/javascript"
                 (str (ps* `(progn
                              (var *slideshow-name* ,slideshow-name)
                              (var *images* (array ,@images))
                              (var *current-image-index* ,current-image-index)))))
        (:script :type "text/javascript" :src "/y")
        )
       (:body
        (:div :id "slideshow-container"
              :style "width:100%;text-align:center"
              (:img :id "slideshow-img-object"
                    :src (slideshow-image-uri slideshow-name
                                              (elt images current-image-index)))
              :br
              (:a :href (format nil "?image=~a" (elt images previous-image-index))
                  :onclick (ps (previous-image) (return false))
                  "Previous")
              " "
              (:a :href (format nil "?image=~a" (elt images next-image-index))
                  :onclick (ps (next-image) (return false))
                  "Next")
              ))))))

(restas:define-route x ("/x")
  (slideshow-handler "pic"))

(restas:define-route z ("/z")
  (slideshow-handler "img"))
(in-package #:moto)

(defmacro/ps s+ (&body body)
  `(concatenate 'string ,@body))

(defmacro/ps btn+ (name value onclick)
  `(s+ "<input type='button' name='" ,name
       "' value='" ,value
       "' onclick='" ,onclick
       ";return false;' />"))

(defmacro/ps asm+ (id name salary-text)
  `(s+ "<li id=\"" ,id "\">"
       "<span class=\"handle\">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;"
       ,name
       "&nbsp;"
       "<span style='color: red'>" ,salary-text "</span>"
       "</li>"))

(restas:define-route collection ("/collection")
  (labels ((asm-node (x)
             (asm+ (format nil "~A" (id x))
                   (name x)
                   (let ((it (salary-text x)))
                     (if (equal it "false") "" it))))
           (mrg (param)
             (if (null param)
                 (ps-html ((:li :id 0)
                           "Нет вакансий"))
                 (reduce #'(lambda (x y)
                             (concatenate 'string x (string #\NewLine) y))
                         (mapcar #'(lambda (x)
                                     (asm-node x))
                                 param)))))
    (let* ((vacs (aif (find-vacancy :profile-id 1) it (err "null vacancy")))
           (sorted-vacs (sort vacs #'(lambda (a b) (> (salary a) (salary b)))))
           (not-interesting)
           (interesting)
           (unsort))
      (loop :for vac :in sorted-vacs :do
         (if (equal 0 (salary vac))
             (setf not-interesting (append not-interesting (list vac)))
             (if (or (search "android" (string-downcase (name vac)))
                     (search ".net" (string-downcase (name vac)))
                     (search "python" (string-downcase (name vac)))
                     (search "javascript" (string-downcase (name vac)))
                     (search "с#" (string-downcase (name vac)))
                     (search "с++" (string-downcase (name vac)))
                     (search "ruby" (string-downcase (name vac)))
                     (search "SAP" (name vac))
                     (search "1С" (name vac))
                     (search "QA" (name vac))
                     (search "objective-c" (string-downcase (name vac)))
                     (search "ios" (string-downcase (name vac)))
                     (search "delphi" (string-downcase (name vac)))
                     (search "sharepoint" (string-downcase (name vac)))
                     (search "flash" (string-downcase (name vac)))
                     (search "windows" (string-downcase (name vac)))
                     (search "pl/sql" (string-downcase (name vac)))
                     (search "front-end" (string-downcase (name vac)))
                     (and (equal "RUR" (currency vac))
                          (> 50000 (salary vac)))
                     )
                 (setf not-interesting (append not-interesting (list vac)))
                 (if (or (search "php" (string-downcase (name vac)))
                         (search "java" (string-downcase (name vac)))
                         (search "web" (string-downcase (name vac)))
                         (search "backend" (string-downcase (name vac)))
                         (search "back-end" (string-downcase (name vac)))
                         )
                     (setf interesting (append interesting (list vac)))
                     ;; (setf unsort (append unsort (list vac)))
                     ))))
      (with-wrapper
        (ps-html
         ((:link :href "/css/dnd.css" :rel "stylesheet" :media "all"))
         ((:script :src "/js/jquery.sortable.js"))
         ;; (:script (ps
         ;;            (defun up (id)
         ;;              (let* ((obj ((@ $) (+ "#tr" id))))
         ;;                ((@ obj after) ((@ obj prev)))))
         ;;            (defun down (id)
         ;;              (let* ((obj ((@ $) (+ "#tr" id))))
         ;;                ((@ obj before) ((@ obj next)))))
         ;;            (defun asm-teaser (i id name state salary salary-text currency)
         ;;              (s+ "<li id='tr" id "'>"
         ;;                  (s+ "<li>" name "</td>")
         ;;                  "</li>"))
         ;;            (defun load-elts (param)
         ;;              ((@ $ post) "/collection" (create :act param)
         ;;               (lambda (data)
         ;;                 ((@ ((@ $) "#vacancy-container")  html) "")
         ;;                 ((@ $ each) data
         ;;                  (lambda (i data)
         ;;                    ((@ ((@ $) "#vacancy-container")  append)
         ;;                     (asm-teaser i (@ data id) (@ data name) (@ data state)
         ;;                                 (@ data salary) (@ data salary-text) (@ data currency))))))
         ;;               :json))))
         ((:table :border 0)
          ((:tr)
           ((:td)
            ((:textarea :name "code" :id "code" :rows 20 :cols 160)
             (ps
               (defun load-elts (param)
                 ((@ $ post) "/collection" (create :act param)
                  (lambda (data)
                    ((@ ((@ $) "#vacancy-container")  html) "")
                    ((@ $ each) data
                     (lambda (i data)
                       ((@ ((@ $) "#vacancy-container")  append)
                        (s+ "<li id='" (@ data id) "'>" (@ data name) "</li>")))))
                  :json))
               (defun vac-hook (vac)
                 ;; (if (equal 0 (salary vac))
                 ;;     (setf not-interesting (append not-interesting (list vac)))
                 ;;     (if (or (search "android" (string-downcase (name vac)))
                 ;;             (search ".net" (string-downcase (name vac)))
                 ;;             (search "python" (string-downcase (name vac)))
                 ;;             (search "javascript" (string-downcase (name vac)))
                 ;;             (search "с#" (string-downcase (name vac)))
                 ;;             (search "с++" (string-downcase (name vac)))
                 ;;             (search "ruby" (string-downcase (name vac)))
                 ;;             (search "SAP" (name vac))
                 ;;             (search "1С" (name vac))
                 ;;             (search "QA" (name vac))
                 ;;             (search "objective-c" (string-downcase (name vac)))
                 ;;             (search "ios" (string-downcase (name vac)))
                 ;;             (search "delphi" (string-downcase (name vac)))
                 ;;             (search "sharepoint" (string-downcase (name vac)))
                 ;;             (search "flash" (string-downcase (name vac)))
                 ;;             (search "windows" (string-downcase (name vac)))
                 ;;             (search "pl/sql" (string-downcase (name vac)))
                 ;;             (search "front-end" (string-downcase (name vac)))
                 ;;             (and (equal "RUR" (currency vac))
                 ;;                  (> 50000 (salary vac)))
                 ;;             )
                 ;;         (setf not-interesting (append not-interesting (list vac)))
                 ;;         (if (or (search "php" (string-downcase (name vac)))
                 ;;                 (search "java" (string-downcase (name vac)))
                 ;;                 (search "web" (string-downcase (name vac)))
                 ;;                 (search "backend" (string-downcase (name vac)))
                 ;;                 (search "back-end" (string-downcase (name vac)))
                 ;;                 )
                 ;;             (setf interesting (append interesting (list vac)))
                 ;;             (setf unsort (append unsort (list vac)))
                 ;;             )))
                 )
               (load-elts "stub")
               )))
           ((:td)
            ((:a :onclick "loadElts(1); return false") "loadElts(1);")
            (:br)
            ((:a :onclick "eval($('#code').val()); return false;") "eval #code")
            (:br)
            ((:a :onclick "alert(getChildIds('#interesting-container')); return false;") "childs")
            (:br)
            ((:a :onclick "$('.connected').sortable('destroy'); return false;") "destroy")
            (:br)
            ((:a :onclick "$('.connected').sortable({ connectWith: '.connected', handle: '.handle'}); return false;") "make")
            (:br))))
         ((:table :border 0 :style "font-size: small;")
          ((:th) "Интересные")
          ((:th) "Неразобранные")
          ((:th) "Неинтересные")
          ((:tr)
           ((:td :width 500 :valign "top")
            ((:ul :class "connected" :id "interesting-container")
             (mrg interesting)))
           ((:td :width 500 :valign "top")
            ((:ul :class "connected" :id "unsort-container")
             (mrg unsort)))
           ((:td :width 500 :valign "top")
            ((:ul :class "connected" :id "not-interesting-container")
             (mrg not-interesting))))))))))



(restas:define-route collection-post ("/collection" :method :post)
  ;; TODO: Тут перед кодированием можно убирать из пересылаемых данных лишние поля, чтобы не слать их по сети
  (with-wrapper
    (error 'ajax :output (cl-json:encode-json-to-string
                          (aif (find-vacancy :profile-id 1)
                               it
                               (err "null vacancy"))))))
;; iface ends here
