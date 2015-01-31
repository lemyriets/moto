;; [[file:louis.org][iface]]
;;;; 

;;;; iface.lisp

(in-package #:moto)

;; Компилируем шаблоны
(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))

(in-package #:moto)

(defmacro input ((name title &rest rest &key container-class class required type value &allow-other-keys) &body nobody)
  (let ((result-container-class "input-container")
        (label `(:label :for ,name)))
    (when container-class
      (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (when required
      (setf label (append label `(:required "required"))))
    (let ((result-class "form-element input-text"))
      (when required
        (setf result-class (concatenate 'string result-class " required")))
      (when class
        (setf result-class (concatenate 'string result-class " " class)))
      (unless type
        (setf type "text"))
      (unless value
        (setf value ""))
      (remf rest :container-class)
      (remf rest :class)
      (remf rest :required)
      (remf rest :type)
      (remf rest :value)
      (let ((input `(:input :type ,type :name ,name :id ,name :class ,result-class :value ,value)))
        (unless (null rest)
          (setf input (append input rest)))
        (let ((input-container `((:div :class ,result-container-class)
                                 (,label ,title)
                                 (,input))))
          `(ps-html ,input-container))))))

;; (macroexpand-1 '(input ("mobile" "Мобильный телефон" :maxlength "15" :container-class "input-container--1-2 even")))

;; (macroexpand-1 '(input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50")))

;; (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ))
(in-package #:moto)

(defmacro option (value title &rest rest &key &allow-other-keys)
  (let ((option `(:option :value ,value)))
    (unless (null rest)
      (setf option (append option rest)))
    `(ps-html (,option ,title))))

;; (macroexpand-1 '(option "Мужской" "Мужской"))
(in-package #:moto)

(defmacro select ((name title &rest rest &key container-class class required &allow-other-keys) &body options)
  (let ((result-container-class "input-container")
        (label `(:label :for ,name)))
    (when container-class
      (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (when required
      (setf label (append label `(:required "required"))))
    (let ((result-class "form-element"))
      (when required
        (setf result-class (concatenate 'string result-class " required")))
      (remf rest :container-class)
      (remf rest :class)
      (remf rest :required)
      (let ((select `(:select :name ,name :id ,name :class ,result-class)))
        (unless (null rest)
          (setf select (append select rest)))
        (let ((select-container `((:div :class ,result-container-class)
                                  (,label ,title)
                                  (,select ,@options))))
          ;; (when validator-error
          ;;   (setf input-container
          ;;         (append input-container
          ;;                 `(((:p :class "validation-explanation validation-explanation--static hidden") ,@validator-error)))))
          `(ps-html ,select-container))))))

;; (macroexpand-1 '(select ("sex" "Пол")
;;                  (option "Мужской" "Мужской")
;;                  (option "Женский" "Женский")))
(in-package #:moto)

(defmacro fieldset (legend &body body)
  `(ps-html ((:div :class "form-section")
             ((:fieldset)
              ((:legend) ,legend)
              (format nil "~{~A~}"
                      (list ,@body))))))

;; (fieldset "Обязательные поля"
;;   (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
(in-package #:moto)

(defmacro submit (title &rest rest &key class container-class &allow-other-keys)
  (let ((result-container-class "button")
        (result-class "form-send-container"))
    (when container-class (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (remf rest :container-class)
    (when class (setf result-class (concatenate 'string result-class " " class)))
    (remf rest :class)
    (let ((button `(:button :type "submit" :class ,result-container-class)))
      (setf button (append button rest))
      `(ps-html ((:div :class ,result-class)
                 (,button ,title))))))

;; (macroexpand-1 '(submit "Зарегистрироваться" :onclick "alert(1);"))
(in-package #:moto)

(defmacro form ((name title &rest rest &key action method class &allow-other-keys) &body body)
  (let ((result-class "form-section-container")) ;;  js__formValidation
    (unless action (setf action "#"))
    (unless method (setf method "POST"))
    (when class (setf result-class (concatenate 'string result-class " " class)))
    (remf rest :action)
    (remf rest :method)
    (remf rest :class)
    (let ((form `(:form :action ,action :method ,method  :id ,name :name ,name :class ,result-class)))
      (setf form (append form rest))
      `(ps-html (,form
                 ((:input :type "hidden" :name ,(format nil "CSRF-~A" name) :value "d34d75644abf8f1f0b9ee7bbaeb8c178-61d7aa05b65801c3185523a93438a225"))
                 ((:h2 :class "form-headline heading__headline--h2") ,title)
                 (format nil "~{~A~}"
                         (list ,@body)))))))

;; (macroexpand-1 '(form ("regform" "Регистрационные данные")
;;                  (fieldset "Обязательные поля"
;;                    (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
;;                  (fieldset "Необязательные поля"
;;                    (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
;;                  ))

;; (form ("regform" "Регистрационные данные")
;;   (fieldset "Обязательные поля"
;;     (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
;;   (fieldset "Необязательные поля"
;;     (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address.")))
(in-package #:moto)

(defmacro teaser ((&rest rest &key class header &allow-other-keys) &body contents)
  (let ((result-class "teaser-box")
        (inner '((:div :class "inner"))))
    (when class
      (setf result-class (concatenate 'string result-class " " class)))
    (when header
      (setf inner (append inner `(((:div :class "center") ,header)))))
    (setf inner (append inner `(((:p) ,@contents))))
    (remf rest :class)
    (remf rest :header)
    (let ((teaser-box `(:div :class ,result-class)))
      (setf teaser-box (append teaser-box rest))
      `(ps-html
        (,teaser-box ,inner)))))

(macroexpand-1 '(teaser (:header ((:h2 :class "teaser-box--title") "Безопасность данных"))
                 "Адрес электронной почты, телефон и другие
                 данные нигде не показываеются на сайте -
                 мы используем их только для восстановления
                 доступа к аккаунту."
                 ))

;; (macroexpand-1 '(teaser (:header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip") "Безопасность данных"))
;;                  "Пароль к аккаунту храниться в
;;                  зашифрованной форме - даже оператор сайта не
;;                  может прочитать его"
;;                  ))

;; (macroexpand-1 '(teaser (:class "add" :zzz "zzz")
;;                  "Пароль к аккаунту храниться в
;;                  зашифрованной форме - даже оператор сайта не
;;                  может прочитать его"
;;                  ))

  ;; <div class="content-box size-1-5">
  ;;     <div class="teaser-box">
  ;;         <div class="inner">
  ;;             <div class="center">
  ;;                 <h2 class="teaser-box--title">Безопасность данных</h2>
  ;;             </div>
  ;;             <p>
  ;;                 Адрес электронной почты, телефон и другие
  ;;                 данные нигде не показываеются на сайте -
  ;;                 мы используем их только для восстановления
  ;;                 доступа к аккаунту.
  ;;             </p>
  ;;         </div>
  ;;     </div>
  ;;     <div class="teaser-box text-container">
  ;;         <div class="inner">
  ;;             <div class="center">
  ;;                 <img src="https://www.louis.de/content/application/language/de_DE/images/tipp.png" alt="Tip" />
  ;;             </div>
  ;;             <p>Пароль к аккаунту храниться в
  ;;                 зашифрованной форме - даже оператор сайта не
  ;;                 может прочитать его</p>
  ;;         </div>
  ;;     </div>

;; (ps-html
;;  ((:div :class "content-box size-1-5")
;;   (teaser (:header ((:h2 :class "teaser-box--title") "Безопасность данных"))
;;     "Адрес электронной почты, телефон и другие данные нигде не показываеются на сайте - мы используем их только для восстановления доступа к аккаунту."
;;     )
;;   (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
;;     "Пароль к аккаунту храниться в зашифрованной форме - даже оператор сайта не может прочитать его"
;;     )
;;   (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
;;     "Все данные шифруются с использованием <a href=\"#dataprivacy-overlay\" class=\"js__openOverlay\">SSL</a>."
;;     )
;;   (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
;;     "Безопасный пароль должен состоять не менее чем из 8 символов и включать в себя цифры или другие специальные символы"
;;     )))

(in-package #:moto)

(defmacro overlay ((header &rest rest &key container-class class &allow-other-keys) &body contents)
  (let ((result-container-class "overlay")
        (result-class "text-container"))
    (when container-class
      (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (remf rest :container-class)
    (remf rest :class)
    (let ((container `(:div :class ,result-container-class)))
      (setf container (append container rest))
      `(ps-html
        (,container
          ((:a :class "action-icon action-icon--close" :href "#") "Close")
          ,header
          ((:div :class "text-container") ,@contents)
          )))))

;; (macroexpand-1 '(overlay (((:h3 :class "overlay__title") "Information on SSL") :container-class "dataprivacy-overlay" :zzz "zzz")
;;                  ((:h4) "How are my order details protected from prying eyes and manipulation by third parties during transmission?")
;;                  ((:p) "Your order data are transmitted to us using 128-bit SSL (Secure Socket Layer) encryption.")))
(in-package #:moto)

(defmacro heading ((title &rest rest &key class &allow-other-keys) &body body)
  (let ((result-box-class "heading"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      (setf box (append `(,box) `(((:div :class "heading__inner")
                                   ((:div :class "heading__headline")
                                    ((:h1 :class "heading__headline--h1") ,title))))))
      (unless (null body)
        (setf box (append box `(((:div :class "heading__text") ,@body)))))
      `(ps-html ,box))))

;; (macroexpand-1 '(heading ("title") "text"))
(in-package #:moto)

(defmacro breadcrumb (last &rest prevs)
  (let ((acc nil))
    (loop :for (url . title) :in prevs :do
       (setf acc (append acc `(((:span :itemscope "" :itemtype "http://data-vocabulary.org/Breadcrumb")
                                ((:a :href ,url :itemprop "url")
                                 ((:span :itemprop "title") ,title)))
                               "&nbsp;/&nbsp;"))))
    (setf acc (append acc `(((:span) ,last))))
    `(ps-html ,`((:p :class "breadcrumb")
                 ((:span :class "breadcrumb__title") "Вы тут:")
                 ((:span :class "breadcrumb__content") ,@acc
                  )))))

;; (macroexpand-1 '(breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))

;; (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная"))

(in-package #:moto)

(defmacro content-box ((&rest rest &key class &allow-other-keys) &body body)
  (let ((result-box-class "content-box"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      `(ps-html (,box ,@body)))))
(in-package #:moto)

(defmacro system-msg ((msg-type &rest rest &key class &allow-other-keys) &body body)
  "msg-type: sucess | caution | advantage"
  (let ((result-box-class "box system-message"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      (let ((result-icon-type (format nil "result-icon result-icon--~A media__item media__item--left" msg-type)))
        `(ps-html (,box ((:span :class ,result-icon-type))
                        ((:div :class "system-message__text-container")
                         ((:div :class "system-message__text") ,@body))
                        ((:span :class "clear"))))))))

;; (macroexpand-1 '(system-msg ("success") "zzz"))
;; (system-msg (success) "zzz")
(in-package #:moto)

(defmacro system-msg ((msg-type &rest rest &key class &allow-other-keys) &body body)
  "msg-type: sucess | caution | advantage"
  (let ((result-box-class "box system-message"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      (let ((result-icon-type (format nil "result-icon result-icon--~A media__item media__item--left" msg-type)))
        `(ps-html (,box ((:span :class ,result-icon-type))
                        ((:div :class "system-message__text-container")
                         ((:div :class "system-message__text") ,@body))
                        ((:span :class "clear"))))))))


(defmacro standard-page ((&rest rest &key breadcrumb user menu overlay &allow-other-keys) &body body)
  (unless overlay
    (setf overlay ""))
  `(ps-html
    ((:section :class "container")
     ,breadcrumb
     ((:div :class "main hasNavigation")
      ((:div :class "category-nav-container")
       ((:p :class "category-nav-container__headline trail") ,user)
       ((:ul :class "category-nav--lvl0 category-nav") ,menu))
      ((:article :class "content") ,@body)
      ((:div :class "overlay-container popup" :id "dataprivacy-overlay" :data-dontcloseviabg "" :data-mustrevalidate "") ,overlay)
      ((:span :class "clear")))
     ((:div :class "main-ending")
      ((:div :class "last-seen")
       ((:h5) "Items viewed recently")
       ((:p) "You do not have any recently viewed items.")))
     ((:div :class "overlay-bg")))))

;; Враппер веб-интерфейса

;; Хелпер форм

;; Страницы
(in-package #:moto)

(defun menu ()
  (if (null *current-user*)
      (ps-html
       ((:li :class "active")
        ((:a :title "Регистрация" :href "/reg") "Регистрация"))
       ((:li)
        ((:a :title "Логин" :href "/login") "Логин")))
      (ps-html
       ((:li)
        ((:a :title "Пользователи" :href "/users") "Пользователи"))
       ((:li)
        ((:a :title "Группы" :href "/groups") "Группы"))
       ((:li)
        ((:a :title "Профиль" :href (format nil "/user/~A" *current-user*)) "Профиль"))
       ((:li)
        ((:a :title "Сообщения" :href "/im") "Сообщения"))
       ((:li)
        ((:a :title "Выход" :href "/logout") "Выход")))))
    ;; "<a href=\"/load\">Загрузка данных</a>")
    ;; "<a href=\"/\">TODO: Расширенный поиск по ЖК</a>"
    ;; "<a href=\"/cmpxs\">Жилые комплексы</a>"
    ;; "<a href=\"/find\">Простой поиск</a>"
(in-package #:moto)

;; (print
;;  (macroexpand-1 '
;;   (with-wrapper
;;     "<h1>Главная страница</h1>"
;;     )
;;   ))

(restas:define-route main ("/")
  (with-wrapper
      "<h1>Главная страница</h1>"
    ))
(in-package #:moto)

(define-page all-users "/users"
  (ps-html
   ((:h1) "Пользователи")
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список пользователей"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "password")
         (:th "email")
         (:th "ts-create")
         (:th "ts-last")
         (:th "role-id")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-user) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) ((:a :href (format nil "/user/~A" (id i))) (id i)))
                     ((:td) (name i))
                     ((:td) (if (equal 1 *current-user*) (password i) ""))
                     ((:td) (email i))
                     ((:td) (ts-create i))
                     ((:td) (ts-last i))
                     ((:td) (role-id i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать нового пользователя")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя пользователя: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "Пароль: ")
                ((:td) ((:input :type "password" :name "password" :value ""))))
               ((:tr)
                ((:td) "Email: ")
                ((:td) ((:input :type "email" :name "email" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (and (equal 1 *current-user*)
                 (not (equal 1 (id i))))
              (ps-html
               ((:form :method "POST")
                ((:input :type "hidden" :name "act" :value "DEL"))
                ((:input :type "hidden" :name "data" :value (id i)))
                ((:input :type "submit" :value "Удалить"))))
              "")
        (del-user (getf p :data)))
  (:new (ps-html
         ((:input :type "hidden" :name "act" :value "NEW"))
         ((:input :type "submit" :value "Создать")))
        (progn
          (make-user :name (getf p :name)
                     :email (getf p :email)
                     :password (getf p :password)
                     :ts-create (get-universal-time)
                     :ts-last (get-universal-time))
          "Пользователь создан")))
(in-package #:moto)

(define-page all-roles "/roles"
  (ps-html
   ((:h1) "Роли")
   "Роли определяют набор сценариев, которые пользователь выполняет на
сайте. Функционал, который выполняют сценарии запрашивает
разрешение на выполнение действий, которое опирается на роль,
присвоенную пользователю. Пользователь может иметь только одну роль
или не иметь ее вовсе."
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список ролей"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) (id i))
                     ((:td) (name i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать новую роль")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя роли: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (equal 1 *current-user*)
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:input :type "submit" :value "Удалить"))))
            "")
        (if (equal 1 *current-user*)
            (del-role (getf p :data))))
  (:new (if (equal 1 *current-user*)
            (ps-html
             ((:input :type "hidden" :name "act" :value "NEW"))
             ((:input :type "submit" :value "Создать")))
            "")
        (if (equal 1 *current-user*)
            (progn
              (make-role :name (getf p :name))
              "Роль создана")
            "")))
(in-package #:moto)

(define-page all-groups "/groups"
  (ps-html
   ((:h1) "Группы")
   "Группы пользователей определяют набор операций, которые
пользователь может выполнять над объектами системы. В отличие от
ролей, один пользователь может входить в несколько групп или не
входить ни в одну из них."
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список групп"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) (id i))
                     ((:td) (name i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать новую группу")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя шруппы: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (equal 1 *current-user*)
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:input :type "submit" :value "Удалить"))))
            "")
        (if (equal 1 *current-user*)
            (del-group (getf p :data))))
  (:new (if (equal 1 *current-user*)
            (ps-html
             ((:input :type "hidden" :name "act" :value "NEW"))
             ((:input :type "submit" :value "Создать")))
            "")
        (if (equal 1 *current-user*)
            (progn
              (make-group :name (getf p :name))
              "Группа создана")
            "")))
(in-package #:moto)

(in-package #:moto)

(defun user-data-html (u)
  (ps-html
   ((:table :border 0)
    ((:tr)
     ((:td) "id")
     ((:td) (id u)))
    ((:tr)
     ((:td) "name")
     ((:td) (name u)))
    ((:tr)
     ((:td) "password")
     ((:td) (password u)))
    ((:tr)
     ((:td) "email")
     ((:td) (email u)))
    ((:tr)
     ((:td) "ts-create")
     ((:td) (ts-create u)))
    ((:tr)
     ((:td) "ts-last")
     ((:td) (ts-last u)))
    ((:tr)
     ((:td) "role-id")
     ((:td) (role-id u))))))

(in-package #:moto)

(defun change-role-html (u change-role-btn)
  (ps-html
   ((:form :method "POST")
    ((:table :border 0)
     ((:tr)
      ((:td) "Текущая роль:")
      ((:td) ((:select :name "role")
              ((:option :value "0") "Выберите роль")
              (format nil "~{~A~}"
                      (with-collection (i (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))
                        (if (equal (id i) (role-id u))
                            (ps-html
                             ((:option :value (id i) :selected "selected") (name i)))
                            (ps-html
                             ((:option :value (id i)) (name i))))))))
      ((:td) change-role-btn))))))

(in-package #:moto)

(defun change-group-html (u change-group-btn)
  (ps-html
   ((:form :method "POST")
    ((:table :border 0)
     ((:tr)
      ((:td :valign "top") "Группы пользователя:")
      ((:td :valign "top") ((:select :name "groups" :multiple "multiple" :size "7")
                            (format nil "~{~A~}"
                                    (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                                      (if (find (id i) (mapcar #'group-id (find-user2group :user-id (id u))))
                                          (ps-html
                                           ((:option :value (id i) :selected "selected") (name i)))
                                          (ps-html
                                           ((:option :value (id i)) (name i))))))))
      ((:td :valign "top") change-group-btn))))))

(in-package #:moto)

(defun user-msg-html (u)
  (ps-html
   ((:h2) "Сообщения пользователя:")
   ((:a :href (format nil "/user/~A/im/new" (id u))) "Новое сообщение")
   ((:br))
   ((:br))
   (let ((msgs (get-last-msg-dialogs-for-user-id (id u))))
     (if (equal 0 (length msgs))
         "Нет сообщений"
         (msgtpl:dialogs
          (list
           :content
           (format nil "~{~A~}"
                   (loop :for item :in msgs :collect
                      (cond ((equal :rcv (car (last item)))
                             (msgtpl:dlgrcv
                              (list :id (car item)
                                    :from (cadr item)
                                    :time (caddr item)
                                    :msg (cadddr item)
                                    :state (nth 4 item)
                                    :userid (id u)
                                    )))
                            ((equal :snd (car (last item)))
                             (msgtpl:dlgsnd
                              (list :id (car item)
                                    :to (cadr item)
                                    :time (caddr item)
                                    :msg (cadddr item)
                                    :state (nth 4 item)
                                    :userid (id u)
                                    )))
                            (t (err "unknown dialog type")))))))))))

(define-page user "/user/:userid"
  (let* ((i (parse-integer userid))
         (u (get-user i)))
    (if (null u)
        "Нет такого пользователя"
        (format nil "~{~A~}" (with-element (u u)
                               (ps-html
                                ((:h1) (format nil "Страница пользователя #~A - ~A" (id u) (name u)))
                                ((:table :border 0 :cellspacing 10 :cellpadding 10)
                                 ((:tr)
                                  ((:td :valign "top" :bgcolor "#F8F8F8") (user-data-html u))
                                  ((:td :valign "top" :bgcolor "#F8F8F8") (change-role-html u %change-role%))
                                  ((:td :valign "top" :bgcolor "#F8F8F8") (change-group-html u %change-group%)))
                                 ((:tr)
                                  ((:td :valign "top" :bgcolor "#F8F8F8" :colspan 3) (user-msg-html u)))))))))
  (:change-role (if (equal 1 *current-user*)
                    (ps-html
                     ((:input :type "hidden" :name "act" :value "CHANGE-ROLE"))
                     ((:input :type "submit" :value "Изменить")))
                    "")
                (if (equal 1 *current-user*)
                    (let* ((i (parse-integer userid))
                           (u (get-user i)))
                      (aif (getf p :role)
                           (role-id (upd-user u (list :role-id (parse-integer it))))
                           "role changed"))
                    "access-denied"))
  (:change-group (if (equal 1 *current-user*)
                     (ps-html
                      ((:input :type "hidden" :name "act" :value "CHANGE-GROUP"))
                      ((:input :type "submit" :value "Изменить")))
                     "")
                 (if (equal 1 *current-user*)
                     (let* ((i (parse-integer userid))
                            (u (get-user i)))
                       (if (null (getf p :groups))
                           "-not change-"
                           (loop
                              :initially (mapcar #'(lambda (x) (del-user2group (id x)))
                                                 (find-user2group :user-id (parse-integer userid)))
                              :for lnk
                              :in (loop
                                     :for key  :in p    :by #'cddr
                                     :for n    :from 1  :to 10 :by (+ 2)
                                     :when    (equal key :groups)
                                     :collect (parse-integer (nth n p)))
                              :collect (id (make-user2group :user-id i :group-id lnk)))))
                     "access-denied")))
(in-package #:moto)

(define-page userim "/user/:userid/im/:imid"
  (let* ((user-id (parse-integer userid))
         (im-id (parse-integer imid))
         (u (get-user user-id))
         (j (get-user im-id)))
    (if (or (null u) (null j))
        "Нет такого пользователя"
        (let ((msgs (get-msg-dialogs-for-two-user-ids user-id im-id)))
          (if (equal 0 (length msgs))
              "Нет сообщений!"
              (ps-html
               ((:h1) (format nil "Страница диалогов пользователя #~A - ~A с пользователем #~A - ~A"
                              (id u) (name u)
                              (id j) (name j)))
               (msgtpl:dialogs
                (list
                 :content
                 (format nil "~{~A~}"
                         (loop :for item :in msgs :collect
                            (cond ((equal user-id (cadr item))
                                   (msgtpl:dlgrcv
                                    (list :id (car item)
                                          :from (cadr item)
                                          :time (caddr item)
                                          :msg (cadddr item)
                                          :state (nth 4 item)
                                          :userid userid
                                          )))
                                  ((equal im-id (cadr item))
                                   (msgtpl:dlgsnd
                                    (list :id (car item)
                                          :to (cadr item)
                                          :time (caddr item)
                                          :msg (cadddr item)
                                          :state (nth 4 item)
                                          :userid userid
                                          )))
                                  (t (err "err 3536262346")))
                            ))))))))))
(in-package #:moto)

(defmacro label ((&rest rest) &body body)
  (let ((style (format nil "~{~A~^;~}" (mapcar #'(lambda (x) (format nil "~A:~A" (car x) (cdr x)))
                                               '(("color" . "#45688E")
                                                 ("line-height" . "1.27em")
                                                 ("margin" . "0px")
                                                 ("padding" . "26px 0px 9px")
                                                 ("font-size" . "1.09em")
                                                 ("font-weight" . "bold"))))))
    (when (null body)
      (setf body (list "")))
    (if (null rest)
        `(ps-html ((:div :style ,style) ,@body))
        `(ps-html ((:div :style ,style ,@rest) ,@body)))))

(defmacro textarea ((&rest rest) &body body)
  (let ((style (format nil "~{~A~^;~}" (mapcar #'(lambda (x) (format nil "~A:~A" (car x) (cdr x)))
                                               '(("background" . "#FFFFFF")
                                                 ("color" . "black")
                                                 ("border" . "1px solid #C0CAD5")
                                                 ("width" . "490px")
                                                 ("min-height" . "120px")
                                                 ("padding" . "5px 25px 5px 5px")
                                                 ("vertical-align" . "top")
                                                 ("margin" . "0")
                                                 ("overflow" . "auto")
                                                 ("outline" . "0")
                                                 ("line-height" . "150%")
                                                 ("word-wrap" . "break-word")
                                                 ("cursor" . "text"))))))
    (when (null body)
      (setf body (list "")))
    (if (null rest)
        `(ps-html ((:textarea :style ,style) ,@body))
        `(ps-html ((:textarea :style ,style ,@rest) ,@body)))))

(defmacro button ((&rest rest) &body body)
  (let ((style (format nil "~{~A~^;~}" (mapcar #'(lambda (x) (format nil "~A:~A" (car x) (cdr x)))
                                               '(("padding" . "6px 16px 7px 16px")
                                                 ("*padding" . "6px 17px 7px 17px")
                                                 ("margin" . "0")
                                                 ("font-size" . "11px")
                                                 ("display" . "inline-block")
                                                 ("*display" . "inline")
                                                 ("zoom" . "1")
                                                 ("cursor" . "pointer")
                                                 ("white-space" . "nowrap")
                                                 ("outline" . "none")
                                                 ("font-family" . "tahoma, arial, verdana, sans-serif, Lucida Sans")
                                                 ("vertical-align" . "top")
                                                 ("overflow" . "visible")
                                                 ("line-height" . "13px")
                                                 ("text-decoration" . "none")
                                                 ("background" . "none")
                                                 ("background-color" . "#6383a8")
                                                 ("color" . "#FFF")
                                                 ("border" . "0")
                                                 ("*border" . "0")
                                                 ("-webkit-border-radius" . "2px")
                                                 ("-khtml-border-radius" . "2px")
                                                 ("-moz-border-radius" . "2px")
                                                 ("-ms-border-radius" . "2px")
                                                 ("border-radius" . "2px")
                                                 ("-webkit-transition" . "background-color 100ms ease-in-out")
                                                 ("-khtml-transition" . "background-color 100ms ease-in-out")
                                                 ("-moz-transition" . "background-color 100ms ease-in-out")
                                                 ("-ms-transition" . "background-color 100ms ease-in-out")
                                                 ("-o-transition" . "background-color 100ms ease-in-out")
                                                 ("transition" . "background-color 100ms ease-in-out"))))))
    (when (null body)
      (setf body (list "")))
    (if (null rest)
        `(ps-html ((:button :style ,style) ,@body))
        `(ps-html ((:button :style ,style ,@rest) ,@body)))))


(define-page imnew "/user/:userid/im/new"
  (let* ((i (parse-integer userid))
         (u (get-user i)))
    (if (null u)
        "Нет такого пользователя"
        (format nil "~{~A~}"
                (with-element (u u)
                  (ps-html
                   ((:h1) (format nil "Новое сообщения от пользователя #~A - ~A" (id u) (name u)))
                   ((:form :method "POST")
                    ((:div :style "width: 600px; font-family: tahoma,arial,verdana,sans-serif,Lucida Sans; font-size: 11px; font-weight: normal; line-height: 140%;")
                     ((:div :style "background: none repeat scroll 0% 0% #597BA5; padding: 0 10px 10px 10px; position: relative; overflow: hidden;")
                      ((:div :style "padding: 17px 26px 18px; margin: -10px -10px -11px; color: #C7D7E9; transition: color 100ms linear 0s; float: right; text-decoration: none; cursor: pointer;  ") "Закрыть")
                      ((:div :style "color: #FFF; backgound-color: #D7E7F9; padding: 7px 16px; font-weight: bold; font-size: 1.09em; ") "Новое сообщение")
                      ((:div :style "padding: 26px; background: #F7F7F7;")
                       ((:div :style "display: block; margin: 0px; float: right; color: #000;")
                        ((:a :href "/im?sel=3754275" :style "color: #2B587A; text-decoration: none; cursor: pointer;") "Перейти к диалогу"))
                       ((:div :style "padding-top: 0px; color: #45688E; line-height: 1.27em; margin: 0px; padding: 26px 0px 9px; font-size: 1.09em; font-weight: bold; ") "Получатель")
                       ((:select :name "abonent")
                        ((:option :value "0") "Выберите пользователя")
                        (format nil "~{~A~}"
                                (with-collection (i (sort (all-user) #'(lambda (a b) (< (id a) (id b)))))
                                  (if (equal (id i) (id u))
                                      ""
                                      (ps-html
                                       ((:option :value (id i)) (name i)))))))
                       ((:div :style "padding-top: 0px; color: #45688E; line-height: 1.27em; margin: 0px; padding: 26px 0px 9px; font-size: 1.09em; font-weight: bold; ") "Сообщение")
                       (textarea (:name "msg"))
                       ((:div :style "padding-top: 16px")
                        %zzz%)
                       )))))))))
  (:zzz (if (or (equal 1 *current-user*)
                (equal *current-user* (parse-integer userid)))
            (ps-html
             ((:input :type "hidden" :name "act" :value "ZZZ"))
             (button () "Отправить"))
            " [access-denied for send message]")

        (if (or (equal 1 *current-user*)
                (equal *current-user* (parse-integer userid)))
            (create-msg (parse-integer userid) (getf p :abonent) (getf p :msg))
            "access-denied")))
(in-package #:moto)

(defun reg-teasers ()
  (format nil "~{~A~}"
          (list
           (teaser (:header ((:h2 :class "teaser-box--title") "Безопасность данных"))
             "Адрес электронной почты, телефон и другие данные не показываются на сайте - мы используем их только для восстановления доступа к аккаунту.")
           (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
             "Пароль к аккаунту хранится в зашифрованной форме - даже оператор сайта не может прочитать его")
           (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
             "Все данные шифруются с использованием <a href=\"#dataprivacy-overlay\" class=\"js__openOverlay\">SSL</a>.")
           (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
             "Безопасный пароль должен состоять не менее чем из 8 символов и включать в себя цифры или другие специальные символы"))))

(defun reg-overlay ()
  (overlay (((:h3 :class "overlay__title") "Information on SSL") :container-class "dataprivacy-overlay" :zzz "zzz")
    ((:h4) "How are my order details protected from prying eyes and manipulation by third parties during transmission?")
    ((:p) "Your order data are transmitted to us using 128-bit SSL (Secure Socket Layer) encryption.")))

(defun js-reg ()
  (ps-html
   ((:script :type "text/javascript")
    (ps
      (defun get-val (selector)
        ((@ ($ (concatenate 'string "#" selector)) val)))
      (defun empty (string)
        (if (equal "" string) t false))
      (defun contains (string pattern)
        (if (+ 1 ((@ string index-of) pattern)) t false))
      (defun add_explanation (selector content)
        ((@ ((@ ($ (concatenate 'string "#" selector)) parent)) append)
         (lambda (index value)
           (concatenate 'string "<p class='validation-explanation validation-explanation--static'>" content "</p>"))))
      (defun reg-js-valid ()
        ((@ ($ ".validation-explanation") remove))
        (let ((err-cnt 0))
          (when (not (contains (get-val "email")  "@"))
            (add_explanation "email" "Пожалуйста, введите корректный емайл")
            (incf err-cnt))
          (when (empty (get-val "password"))
            (add_explanation "password" "Пожалуйста, введите непустой пароль")
            (incf err-cnt))
          (when (not (equal (get-val "password") (get-val "password-confirm")))
            (add_explanation "password-confirm" "Пожалуйста, введите подтверждение пароля совпадающее с паролем")
            (incf err-cnt))
          (when (empty (get-val "nickname"))
            (add_explanation "nickname" "Никнейм не может быть пустым")
            (incf err-cnt))
          (if (equal err-cnt 0)
            t
            false)))
      ))))

(define-page reg "/reg"
  (let ((breadcrumb (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))
        (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ("Зарегистрируйтесь как пользователь") "После регистрации вы сможете общаться с другими пользователями, искать товары и делать заказы, создавать и отслеживать свои задачи."))
      (content-box (:class "size-3-5 switch-content-container")
        (format nil "~{~A~}"
                (list
                 (if *current-user* (format nil "Кол-во недоставленных сообщений: ~A" (get-undelivered-msg-cnt *current-user*)) "")
                 (js-reg)
                 (form ("regform" "Регистрационные данные") ;;  js__formValidation
                   (fieldset "Обязательные поля"
                     (input ("email" "Электронная почта" :required t :type "email" :maxlength "50"))
                     (input ("password" "Пароль" :required t :type "password" :autocomplete "off"))
                     (input ("password-confirm" "Повторите пароль" :required t :type "password" :autocomplete "off"))
                     (input ("nickname" "Никнейм" :required t :maxlength "50")))
                   (fieldset "Необязательные поля"
                     (input ("firstname" "Имя" :maxlength "25" ))
                     (input ("lastname" "Фамилия" :maxlength "25" ))
                     (input ("phone" "Телефон" :maxlength "15" :container-class "input-container--1-2 odd"))
                     (input ("mobilephone" "Мобильный телефон" :maxlength "15" :container-class "input-container--1-2 even"))
                     (ps-html ((:span :class "clear")))
                     (select ("sex" "Пол")
                       (option "" "Выбрать пол")
                       (option "male" "Мужской")
                       (option "female" "Мужской"))
                     (ps-html
                      ((:div :class "date-container")
                       ((:label :for "date-of-birth") "День рождения")
                       ((:div :class "date-container__inputs fieldset-validation")
                        (input ("birth-day" "" :maxlength "2" :container-class "hide-label input-container--1st"))
                        (input ("birth-month" "" :maxlength "2" :container-class "hide-label input-container--2nd input-container--middle"))
                        (input ("birth-year" "" :maxlength "4" :container-class "hide-label input-container input-container--3rd")))))
                     )
                   %REGISTER%))))
      (content-box (:class "size-1-5") (reg-teasers))
      (ps-html ((:span :class "clear")))))
  (:register (ps-html
              ((:input :type "hidden" :name "act" :value "REGISTER"))
              (submit "Зарегистрироваться" :onclick (ps (return (reg-js-valid)))))
             (macrolet ((get-val (selector)
                          `(getf p ,(intern (string-upcase selector) :keyword))))
               (defun reg-ctrl-valid (p)
                 (let ((errors))
                 (when (not (contains (get-val "email")  "@"))
                   (push "Пожалуйста, введите корректный емайл" errors))
                 (when (empty (get-val "password"))
                   (push "Пожалуйста, введите непустой пароль" errors))
                 (when (not (equal (get-val "password") (get-val "password-confirm")))
                   (push "Пожалуйста, введите подтверждение пароля совпадающее с паролем" errors))
                 (when (empty (get-val "nickname"))
                   (push "Никнейм не может быть пустым" errors))
                   errors))
               (aif (reg-ctrl-valid p)
                    ;; Возвращены ошибки
                    (dbg "~A" (bprint it))
                    ;; Ошибок нет, cоздаем пользователя
                    (let* ((user-id (create-user (getf p :nickname) (getf p :password) (getf p :email)))
                           (user (get-user user-id)))
                      (dbg "~A :|<BR/>|: ~A" (bprint p) user-id)
                      ;; И сохраняем его id в сесии и thread-local переменной *current-user*
                      (setf (hunchentoot:session-value 'current-user) user-id)
                      (setf *current-user* user-id)
                      ;; Заполняем поля пользователя
                      (upd-user user (list :firstname   (getf p :firstname)     :lastname    (getf p :lastname)       :phone       (getf p :phone)
                                           :mobilephone (getf p :mobilephone)   :sex         (getf p :sex)            :birth-day   (getf p :birth-day)
                                           :birth-month (getf p :birth-month)   :birth-year  (getf p :birth-year)))
                      ;; Выводим страничку о успешной регистрации
                      (let ((breadcrumb (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))
                            (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
                        (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
                          (content-box ()
                            (heading ("Успешная регистрация")))
                          (content-box ()
                            (system-msg ("success")
                              (let ((tmp (format nil "Подтверждение регистрации будет выслано на <b>~A</b> в течение пары дней. ~A"
                                                 (getf p :email)
                                                 "Вы можете использовать свой email и пароль для входа в профиль в любое время")))
                                (ps-html ((:p) "Ваши регистрационные данные успешно сохранены")
                                         ((:p) tmp)))))
                          (ps-html ((:span :class "clear"))))))))))
;; iface ends here
