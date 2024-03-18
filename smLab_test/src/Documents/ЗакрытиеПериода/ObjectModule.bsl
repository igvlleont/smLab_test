
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Движения.ПартииТоваров.Записывать = Истина;
	Движения.ПозицииЗакрытияПериода.Записывать = Истина;
	
	БлокировкаДанных = Новый БлокировкаДанных();
	
	ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрСведений.ПозицииЗакрытияПериода");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.УстановитьЗначение("Организация", Организация);
	
	ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрНакопления.ПартииТоваров");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.УстановитьЗначение("Организация", Организация);
	
	ЭлементБлокировки = БлокировкаДанных.Добавить("РегистрНакопления.ОстаткиТоваров");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.УстановитьЗначение("Организация", Организация);

	БлокировкаДанных.Заблокировать();
	
	ПоследняяГраницаКонтроля = РегистрыСведений.ПозицииЗакрытияПериода.ПолучитьТекущуюПозициюРегистра(Организация);
	
	ТекущаяГраницаКонтроля = КонецДня(ГраницаПериода);
	
	Если ПоследняяГраницаКонтроля >= ТекущаяГраницаКонтроля Тогда		
		ТекстОшибки = СтрШаблон(Нстр("ru = 'Текущая позиция закрытия периода:''%1'' больше Границы периода документа:''%2'''"), ПоследняяГраницаКонтроля, ТекущаяГраницаКонтроля);
		ОбщегоНазначения.СообщитьПользователю(ТекстОшибки, ЭтотОбъект, "ГраницаПериода",, Отказ);
		Возврат;
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ПартииТоваровОстатки.Номенклатура КАК Номенклатура,
	|	ПартииТоваровОстатки.ПартияНоменклатуры,
	|	ПартииТоваровОстатки.КоличествоОстаток
	|ПОМЕСТИТЬ ВТ_ОстаткиПартий
	|ИЗ
	|	РегистрНакопления.ПартииТоваров.Остатки(&КонецПериода, Организация = &Организация) КАК ПартииТоваровОстатки
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОстаткиТоваровОстаткиИОбороты.Номенклатура КАК Номенклатура,
	|	ОстаткиТоваровОстаткиИОбороты.КоличествоРасход
	|ПОМЕСТИТЬ ВТ_ОстаткиРасход
	|ИЗ
	|	РегистрНакопления.ОстаткиТоваров.ОстаткиИОбороты(&НачалоПериода, &КонецПериода, Авто,,
	|		Организация = &Организация) КАК ОстаткиТоваровОстаткиИОбороты
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ОстаткиРасход.Номенклатура КАК Номенклатура,
	|	ВТ_ОстаткиРасход.КоличествоРасход КАК КоличествоРасход,
	|	ВТ_ОстаткиПартий.ПартияНоменклатуры КАК ПартияНоменклатуры,
	|	ЕстьNULL(ВТ_ОстаткиПартий.КоличествоОстаток, 0) КАК КоличествоВПартии,
	|	ВТ_ОстаткиПартий.ПартияНоменклатуры.Дата КАК ДатаПартии
	|ИЗ
	|	ВТ_ОстаткиРасход КАК ВТ_ОстаткиРасход
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОстаткиПартий КАК ВТ_ОстаткиПартий
	|		ПО ВТ_ОстаткиРасход.Номенклатура = ВТ_ОстаткиПартий.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаПартии
	|ИТОГИ
	|	КОЛИЧЕСТВО(ПартияНоменклатуры) КАК ПартияНоменклатуры,
	|	МАКСИМУМ(КоличествоРасход) КАК КоличествоРасход,
	|	СУММА(КоличествоВПартии),
	|	МАКСИМУМ(ДатаПартии) КАК ДатаПартии
	|ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("НачалоПериода", ПоследняяГраницаКонтроля);
	Запрос.УстановитьПараметр("КонецПериода", ТекущаяГраницаКонтроля);
	
	Результат = Запрос.Выполнить();
	ВыборкаНоменклатура = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Номенклатура");
	ТекстОшибки = "Список ошибок выполнения процедуры закрытия:" + Символы.ПС;
	Ошибка = Ложь;
	Пока ВыборкаНоменклатура.Следующий() Цикл
		ПланОбщийРасход = ВыборкаНоменклатура.КоличествоРасход;
		ОстатокПартий = ВыборкаНоменклатура.КоличествоВПартии;
		
		Если ОстатокПартий < ПланОбщийРасход Тогда
			 ТекстОшибки = ТекстОшибки + Символы.ПС + СтрШаблон(Нстр("ru = 'Для номенклатуры:''%1'' расход (%2) превышает допустимое количество в партиях: %3'"),
			 Строка(ВыборкаНоменклатура.Номенклатура) , ПланОбщийРасход, ОстатокПартий);
			 Ошибка = Истина;
			 Продолжить;
		КонецЕсли;
			
		Выборка = ВыборкаНоменклатура.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			 НовоеДвижение = Движения.ПартииТоваров.Добавить();
			 НовоеДвижение.Период = ТекущаяГраницаКонтроля;
			 НовоеДвижение.ВидДвижения = ВидДвиженияНакопления.Расход;			 
			 НовоеДвижение.Организация = Организация;
			 НовоеДвижение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
			 НовоеДвижение.ПартияНоменклатуры = Выборка.ПартияНоменклатуры;
			 Если ПланОбщийРасход <= Выборка.КоличествоВПартии Тогда
			 	  НовоеДвижение.Количество = ПланОбщийРасход;
			 	  ПланОбщийРасход = 0;
			 	  Прервать;
			 Иначе	
			 	  НовоеДвижение.Количество = Выборка.КоличествоВПартии;
			 	  ПланОбщийРасход = ПланОбщийРасход - Выборка.КоличествоВПартии;
			 КонецЕсли;	
		КонецЦикла;	
		
		Если ПланОбщийРасход <> 0 Тогда
			 ТекстОшибки = ТекстОшибки + Символы.ПС + СтрШаблон(Нстр("ru = 'Для номенклатуры:''%1'' хватает остатка по партиям на: %1'"),
			 Строка(ВыборкаНоменклатура.Номенклатура) , ПланОбщийРасход);
			 Ошибка = Истина;
		КонецЕсли;		
			
	КонецЦикла;
	
	Если Ошибка Тогда	 
		 ОбщегоНазначения.СообщитьПользователю(ТекстОшибки, ЭтотОбъект,,, Отказ);	
	КонецЕсли;
	
	НовоеДвижение = Движения.ПозицииЗакрытияПериода.Добавить();
	НовоеДвижение.Период = ТекущаяГраницаКонтроля;			 
	НовоеДвижение.Организация = Организация;
	НовоеДвижение.ГраницаПериода = ТекущаяГраницаКонтроля;
	
	Движения.Записать();
	
	
		 
КонецПроцедуры

#КонецОбласти

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли
