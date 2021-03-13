﻿#Область ОписаниеПеременных

&НаКлиенте
Перем ПутьКОбработке; // каталог обработки

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	УбратьПодтверждениеПриЗавершенииПрограммы();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	СтрокаЗапуска = СокрЛП(ПараметрЗапуска);
	
	Если СтрокаЗапуска = "" Тогда
		ПоказатьСправкуВЛоге();
		Возврат;
	КонецЕсли;

	ЗавершитьРаботуСистемы = Истина;
	
	Попытка
		ПутьКОбработке = ПолучитьПутьОбработки();

		ПараметрыКоманднойСтроки = ПолучитьСтруктуруПараметров(СтрокаЗапуска);
		ПреобразоватьПараметрыКоторыеНачинаютсяСТочкиКНормальнымПутям(ПараметрыКоманднойСтроки);
		
		ПутьРасширения = ЗначениеПараметра("Путь", ПараметрыКоманднойСтроки, 
			"Не задано имя расширения - формат Путь=НужныйПутьФайлаРасширения");

		ИмяРасширения = ЗначениеПараметра("Имя", ПараметрыКоманднойСтроки, 
			"Не задано имя расширения - формат Имя=МоеИмя");
		
		Перезаписывать = ЗначениеПараметраБулево("Перезаписывать", ПараметрыКоманднойСтроки);
		БезопасныйРежимРасширения = ЗначениеПараметраБулево("БезопасныйРежим", ПараметрыКоманднойСтроки);
		ЗащитаОтОпасныхДействийРасширения = ЗначениеПараметраБулево("ЗащитаОтОпасныхДействий", ПараметрыКоманднойСтроки);
		ЗавершитьРаботуСистемы = ЗначениеПараметраБулево("ЗавершитьРаботуСистемы", ПараметрыКоманднойСтроки, Истина);

	Исключение
		ОписаниеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		Ошибка = СтрШаблон("Неудача при обработке параметров запуска %1Параметры: %2 %1%3 %1",
			Символы.ПС, СтрокаЗапуска, ОписаниеОшибки);
		Лог(Ошибка);

		ПоказатьСправкуВЛоге();

		Если ЗавершитьРаботуСистемы Тогда
			ЗавершитьРаботу();
			Возврат;
		КонецЕсли;
	КонецПопытки;

	Попытка
		
		ЗагрузитьРасширения(ПутьРасширения, ИмяРасширения, Перезаписывать, 
			БезопасныйРежимРасширения, ЗащитаОтОпасныхДействийРасширения,
			ЗавершитьРаботуСистемы);

	Исключение
		ОписаниеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		Ошибка = СтрШаблон("Неудача при выполнении основного кода %1%2 %1",
			Символы.ПС, ОписаниеОшибки);
		Лог(Ошибка);

		Если ЗавершитьРаботуСистемы Тогда
			ЗавершитьРаботу();
		КонецЕсли;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Основное

&НаКлиенте
Процедура ПоказатьСправкуВЛоге()
	
	Лог("
		|Помощь:
		|Формат параметров Путь=КаталогФайлов;Имя=ИмяРасширения;Перезаписывать;БезопасныйРежим;ЗащитаОтОпасныхДействий;ЗавершитьРаботуСистемы;
		|  или Путь=ПутьФайла;БезопасныйРежим=Истина;ЗащитаОтОпасныхДействий=Ложь;ЗавершитьРаботуСистемы;
		|
		|Любые параметры, кроме первого (Путь,Имя), являются необязательными.
		|Если параметр (БезопасныйРежим;ЗащитаОтОпасныхДействий;ЗавершитьРаботуСистемы) не указан, расширение будет загружено без него.
		|Если параметр Перезаписывать указан, если соответствующие расширение будет переустановлено.
		|	Если параметр Перезаписывать не указан, будет выдана ошибка, если расширение с таким именем уже установлено!.
		|Если указано ЗавершитьРаботуСистемы=Ложь, работа 1С:Предприятия не будет завершена.
		|
		|По умолчанию простой режим запуска Путь=Путь загружает расширение из файла, отключая безопасный режим и защиту от опасных действий.
		|Пример запуска через vanessa-runner - vrunner run --command ""Путь=./МоеРасширение.cfe;ЗавершитьРаботуСистемы"" --execute $runnerRoot\epf\ЗагрузитьРасширениеВРежимеПредприятия.epf",
		
		"Информация");

КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьРасширения(ПутьРасширения, Знач ИмяРасширения, Перезаписывать, 
						БезопасныйРежим, ЗащитаОтОпасныхДействий,
						ЗавершитьРаботуСистемы)

	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("ПутьРасширения", ПутьРасширения);
	ДопПараметры.Вставить("ИмяРасширения", ИмяРасширения);
	ДопПараметры.Вставить("Перезаписывать", Перезаписывать);
	ДопПараметры.Вставить("БезопасныйРежим", БезопасныйРежим);
	ДопПараметры.Вставить("ЗащитаОтОпасныхДействий", ЗащитаОтОпасныхДействий);
	ДопПараметры.Вставить("ЗавершитьРаботуСистемы", ЗавершитьРаботуСистемы);
	
	Обработчик = Новый ОписаниеОповещения("ОбработкаПоискаРасширенийВКаталоге", ЭтаФорма, ДопПараметры);
	НачатьПоискФайлов(Обработчик, ПутьРасширения, "*.cfe", Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаПоискаРасширенийВКаталоге(Знач НайденныеФайлы, Знач ДопПараметры) Экспорт
	
	Попытка
		
		ПутьРасширения = ДопПараметры.ПутьРасширения;
		ИмяРасширения = ДопПараметры.ИмяРасширения;
		Перезаписывать = ДопПараметры.Перезаписывать;
		БезопасныйРежим = ДопПараметры.БезопасныйРежим;
		ЗащитаОтОпасныхДействий = ДопПараметры.ЗащитаОтОпасныхДействий;
		ЗавершитьРаботуСистемы = ДопПараметры.ЗавершитьРаботуСистемы;
		
		Если Не ЗначениеЗаполнено(НайденныеФайлы) Тогда
			НайденныеФайлы = Новый Массив;
			Файл = Новый Файл(ПутьРасширения);
			НайденныеФайлы.Добавить(Файл);
		КонецЕсли;

		Если Не ЗначениеЗаполнено(НайденныеФайлы) Тогда
			ВызватьИсключение "Не найдено файлов-расширений для пути " + ПутьРасширения;
		КонецЕсли;
		
		Для Каждого Файл Из НайденныеФайлы Цикл
			ПутьФайла = Файл.ПолноеИмя;
			ДвоичныеДанные = Новый ДвоичныеДанные(ПутьФайла);
			
			Если ПустаяСтрока(ИмяРасширения) Тогда
				ИмяРасширения = Файл.ИмяБезРасширения;
			КонецЕсли;
			
			Попытка
				УстановитьРасширение(ИмяРасширения, ДвоичныеДанные, Перезаписывать, 
					БезопасныйРежим, ЗащитаОтОпасныхДействий);
			Исключение
				ВызватьИсключение ПутьФайла + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			КонецПопытки;
			
		КонецЦикла;
		
		ОбновитьПараметрыРаботыВерсийРасширений();
	Исключение
		ОписаниеОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		
		Ошибка = СтрШаблон("Неудача при выполнении основного кода %1%2 %1",
			Символы.ПС, ОписаниеОшибки);
		Лог(Ошибка);

	КонецПопытки;
	
	Если ЗавершитьРаботуСистемы Тогда
		ЗавершитьРаботу();
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура УстановитьРасширение(Имя, ДвоичныеДанныеРасширения, Перезаписывать, 
								БезопасныйРежим, ЗащитаОтОпасныхДействий, ПовторнаяУстановка = Ложь)
								
	ОписаниеЗащиты = Новый("ОписаниеЗащитыОтОпасныхДействий");
	ОписаниеЗащиты.ПредупреждатьОбОпасныхДействиях = ЗащитаОтОпасныхДействий;
	
	Расширение = РасширенияКонфигурации.Создать();
	Расширение.БезопасныйРежим = БезопасныйРежим;
	Расширение.ЗащитаОтОпасныхДействий = ОписаниеЗащиты;
	
	Попытка
		Расширение.Записать(ДвоичныеДанныеРасширения);
	Исключение
		ИнфоОшибки = ИнформацияОбОшибке();
		ОписаниеОшибки = ОписаниеОшибки();
		
		Если ПовторнаяУстановка Тогда
			ВызватьИсключение;
		КонецЕсли;
		
		ЛогСервер("Расширение не удалось установить. Пытаюсь удалить существующее расширение по имени и повторно установить
		|Проблема:
		|" + ОписаниеОшибки, "");

		УдалитьРасширение(Имя);
		УстановитьРасширение(Имя, ДвоичныеДанныеРасширения, Перезаписывать,
			БезопасныйРежим, ЗащитаОтОпасныхДействий, Истина);
			
		Возврат;
		
	КонецПопытки;
	
	СообщитьОбУспешнойУстановке(БезопасныйРежим, ЗащитаОтОпасныхДействий, Имя);
	
КонецПроцедуры

&НаСервере
Процедура УдалитьРасширение(Имя)
	
	Расширение = РасширениеПоИмени(Имя);

	Расширение.Удалить();
	
	ЛогСервер("Расширение удалено: " + Имя, "");
	
КонецПроцедуры

&НаСервере
Функция РасширениеПоИмени(Знач Имя)
	
	Отбор = Новый Структура("Имя", Имя);
	Расширения = РасширенияКонфигурации.Получить(Отбор);
	Если Не ЗначениеЗаполнено(Расширения) Тогда
		ВызватьИсключение "Не удалось найти расширение по имени " + Имя;
	КонецЕсли;
	
	Возврат Расширения[0];

КонецФункции

&НаСервере
Процедура СообщитьОбУспешнойУстановке(Знач БезопасныйРежим, Знач ЗащитаОтОпасныхДействий, Знач Имя)
	
	Перем Расширение, Сообщение, Уровень;
	
	Уровень = "Информация";
	
	Расширение = РасширениеПоИмени(Имя);
	ЛогСервер(СтрШаблон("Установлено расширение %1, версия %2", Расширение.Имя , Расширение.Версия), Уровень);
	
	Если БезопасныйРежим Тогда
		Сообщение = "Безопасный режим установлен!";
	Иначе
		Сообщение = "Безопасный режим снят!";
	КонецЕсли;
	ЛогСервер(Сообщение, Уровень);
	
	Если ЗащитаОтОпасныхДействий Тогда
		Сообщение = "Защита от опасных действий установлена!";
	Иначе
		Сообщение = "Защита от опасных действий снята!";
	КонецЕсли;
	ЛогСервер(Сообщение, Уровень);

КонецПроцедуры

&НаСервере
Процедура ОбновитьПараметрыРаботыВерсийРасширений()
	
	Если Метаданные.Подсистемы.Найти("СтандартныеПодсистемы") <> Неопределено Тогда 
		МодульРегистрыСведенийПараметрыРаботыВерсийРасширений = Вычислить("РегистрыСведений.ПараметрыРаботыВерсийРасширений");
		МодульРегистрыСведенийПараметрыРаботыВерсийРасширений.ОбновитьПараметрыРаботыРасширений();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область БиблиотекаЗапускаВанессаРаннер

&НаСервере
Процедура УбратьПодтверждениеПриЗавершенииПрограммы()

	Если Метаданные.Подсистемы.Найти("СтандартныеПодсистемы") <> Неопределено Тогда 
		МодульОбщегоНазначения = Вычислить("ОбщегоНазначения");
		Попытка
			МодульОбщегоНазначения.ХранилищеОбщихНастроекСохранить("ОбщиеНастройкиПользователя",
				"ЗапрашиватьПодтверждениеПриЗавершенииПрограммы", Ложь);

		Исключение
			// Данного модуля и метода может не быть в конфигурации
			ЛогСервер("Неудача в УбратьПодтверждениеПриЗавершенииПрограммы. Конфигурация не основана на БСП?", "Предупреждение");
		КонецПопытки;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Функция ПолучитьПутьОбработки()

	Перем ФайлПути, Результат;

	Результат = ПолучитьПутьКОбработкеСервер();
	Если НЕ ПустаяСтрока(ПутьКОбработке) Тогда
		ФайлПути = Новый Файл(ПутьКОбработке);
		Результат = ФайлПути.Путь;
	КонецЕсли;

	Возврат Результат;
КонецФункции

&НаСервере
// портировано из Vanessa-ADD
Функция ПолучитьПутьКОбработкеСервер()

	ОбъектНаСервере = ОбъектНаСервере();
	ИспользуемоеИмяФайла = ОбъектНаСервере.ИспользуемоеИмяФайла;
	ПрефиксИмени = НРег(Лев(ИспользуемоеИмяФайла, 6));
    Если (ПрефиксИмени <> "e1cib/") И (ПрефиксИмени <> "e1cib\") Тогда
		Возврат ИспользуемоеИмяФайла;
	КонецЕсли;

	Возврат "";
КонецФункции

Функция ОбъектНаСервере()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции

&НаКлиенте
// портировано из Vanessa-ADD
Функция ПолучитьСтруктуруПараметров(Стр)
	Результат = Новый Структура;

	Массив = РазложитьСтрокуВМассивПодстрок(Стр, ";");
	Для каждого Элем Из Массив Цикл
		Поз = Найти(Элем, "=");
		Если Поз > 0 Тогда
			Ключ     = Лев(Элем, Поз - 1);
			Значение = Сред(Элем, Поз + 1);
			Попытка
				Результат.Вставить(СокрЛП(Ключ), СокрЛП(Значение));
			Исключение
				Лог("Не смог получить значение из строки запуска: " + Ключ);
			КонецПопытки;
		Иначе
			Если НЕ ПустаяСтрока(Элем) Тогда
				Попытка
					Результат.Вставить(Элем, Истина);
				Исключение
					Лог("Не смог получить значение из строки запуска: " + Элем);
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ЗначениеПараметра(Знач ИмяПараметра, Знач ПараметрыКоманднойСтроки, Знач ТекстОшибки)
	
	Результат = "";
	Если Не ПараметрыКоманднойСтроки.Свойство(ИмяПараметра, Результат)
			Или Не ЗначениеЗаполнено(Результат) Тогда
			
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция ЗначениеПараметраБулево(Знач ИмяПараметра, Знач ПараметрыКоманднойСтроки, Знач ПоУмолчанию = Ложь)
	
	Результат = Ложь;
	Если Не ПараметрыКоманднойСтроки.Свойство(ИмяПараметра, Результат)
			Или Не ЗначениеЗаполнено(Результат) Тогда
			
		Возврат ПоУмолчанию;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
// портировано из Vanessa-ADD
Функция РазложитьСтрокуВМассивПодстрок(Знач Строка, Знач Разделитель = ",",
		Знач ПропускатьПустыеСтроки = Неопределено)

	Результат = Новый Массив;

	// для обеспечения обратной совместимости
	Если ПропускатьПустыеСтроки = Неопределено Тогда
		ПропускатьПустыеСтроки = ?(Разделитель = " ", Истина, Ложь);
		Если ПустаяСтрока(Строка) Тогда
			Если Разделитель = " " Тогда
				Результат.Добавить("");
			КонецЕсли;
			Возврат Результат;
		КонецЕсли;
	КонецЕсли;

	Позиция = Найти(Строка, Разделитель);
	Пока Позиция > 0 Цикл
		Подстрока = Лев(Строка, Позиция - 1);
		Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Подстрока) Тогда
			Результат.Добавить(Подстрока);
		КонецЕсли;
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
		Позиция = Найти(Строка, Разделитель);
	КонецЦикла;

	Если Не ПропускатьПустыеСтроки Или Не ПустаяСтрока(Строка) Тогда
		Результат.Добавить(Строка);
	КонецЕсли;

	Возврат Результат;

КонецФункции

&НаКлиенте
// портировано из Vanessa-ADD
Процедура ПреобразоватьПараметрыКоторыеНачинаютсяСТочкиКНормальнымПутям(СтруктураПараметров)
	МассивКлючей = Новый Массив;

	Для каждого ПараметрБилда Из СтруктураПараметров Цикл
		Если Лев(ПараметрБилда.Значение, 1) = "."  Или
				Найти(ПараметрБилда.Значение, "$instrumentsRoot") > 0 Тогда

			МассивКлючей.Добавить(ПараметрБилда.Ключ);

		КонецЕсли;
	КонецЦикла;

	Для каждого Ключ Из МассивКлючей Цикл
		Было  = СтруктураПараметров[Ключ];
		Стало = ПреобразоватьПутьСТочкамиКНормальномуПути(СтруктураПараметров[Ключ]);
		Стало = ЗаменитьСлеши(Стало);
		
		СтруктураПараметров.Вставить(Ключ, Стало);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Функция ПреобразоватьПутьСТочкамиКНормальномуПути(ОригСтр)

	Если Найти(ОригСтр, "$instrumentsRoot") > 0 И НЕ ПустаяСтрока(ПутьКОбработке) Тогда
		ОригСтр = СтрЗаменить(ОригСтр, "$instrumentsRoot", ДополнитьСлешВПуть(ПутьКОбработке));
		Возврат ОригСтр;
	КонецЕсли;

	Возврат ОригСтр;

КонецФункции

// Функция ДополнитьСлешВПуть
//
// Параметры: ИмяКаталога
//
// Описание:
// Функция дополняет и возвращает слеш в путь в конец строки, если он отсутствует
//
// портировано из Vanessa-ADD
//
&НаКлиенте
Функция ДополнитьСлешВПуть(Знач Каталог)
	разделитель = ПолучитьРазделительПути();

	Если ПустаяСтрока(Каталог) Тогда
		Возврат Каталог;
	КонецЕсли;

	Если Прав(Каталог, 1) <> разделитель Тогда
		Каталог = Каталог + разделитель;
	КонецЕсли;
	Возврат Каталог;
КонецФункции

&НаКлиенте
Функция ЗаменитьСлеши(Знач Путь)
	Результат = СтрЗаменить(Путь, "\", ПолучитьРазделительПути());
	Результат = СтрЗаменить(Результат, "/", ПолучитьРазделительПути());
	Возврат Результат;
КонецФункции

&НаКлиенте
Процедура ЗавершитьРаботу() 
	// в таком варианте 1С не отдает лог в файл своего лога ( -- ПрекратитьРаботуСистемы(Ложь); 
	ЗавершитьРаботуСистемы(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура Лог(Знач Комментарий, Знач Уровень = "Ошибка")

	Если Не ЗначениеЗаполнено(Уровень) Тогда
		Уровень = "Информация";
	КонецЕсли;

	СообщениеПользователю = Новый СообщениеПользователю;
	СообщениеПользователю.Текст = Уровень + ": " + Комментарий;
	СообщениеПользователю.Сообщить();

	ЗаписьЖурналаРегистрацииСервер(Комментарий, Уровень);

КонецПроцедуры

&НаСервере
Процедура ЛогСервер(Знач Комментарий, Знач Уровень = "Ошибка")

	Если Не ЗначениеЗаполнено(Уровень) Тогда
		Уровень = "Информация";
	КонецЕсли;

	СообщениеПользователю = Новый СообщениеПользователю;
	СообщениеПользователю.Текст = Уровень + ": " + Комментарий;
	СообщениеПользователю.Сообщить();

	ЗаписьЖурналаРегистрацииСервер(Комментарий, Уровень);

КонецПроцедуры

&НаСервере
Процедура ЗаписьЖурналаРегистрацииСервер(Знач Комментарий, Знач Уровень)

	Если НРег(Уровень) = "ошибка" Тогда
		УровеньЖР = УровеньЖурналаРегистрации.Ошибка;
	ИначеЕсли НРег(Уровень) = "предупреждение" Тогда
		УровеньЖР = УровеньЖурналаРегистрации.Предупреждение;
	Иначе
		УровеньЖР = УровеньЖурналаРегистрации.Информация;
	КонецЕсли;

	ЗаписьЖурналаРегистрации(КлючЖР(), УровеньЖР, Неопределено, Неопределено, Комментарий);

КонецПроцедуры

#КонецОбласти

&НаСервере
Функция КлючЖР()
	Возврат "VanessaRunner." + ОбъектНаСервере().Метаданные().Имя;
КонецФункции

#КонецОбласти
