/* -*- Mode: C; shift-width: 8; tab-width: 8; indent-tabs-mode: t; c-basic-offset: 8 -*- */
/*
 * get2gnow is:
 * 	Copyright (c) 2006-2009 Kaity G. B. <uberChick@uberChicGeekChick.Com>
 * 	Released under the terms of the Reciprocal Public License (RPL).
 *
 * For more information or to find the latest release, visit our
 * website at: http://uberChicGeekChick.Com/?projects=get2gnow
 *
 * Writen by an uberChick, other uberChicks please meet me & others @:
 * 	http://uberChicks.Net/
 *
 * I'm also disabled. I live with a progressive neuro-muscular disease.
 * DYT1+ Early-Onset Generalized Dystonia, a type of Generalized Dystonia.
 * 	http://Dystonia-DREAMS.Org/
 *
 *
 *
 * Unless explicitly acquired and licensed from Licensor under another
 * license, the contents of this file are subject to the Reciprocal Public
 * License ("RPL") Version 1.5, or subsequent versions as allowed by the RPL,
 * and You may not copy or use this file in either source code or executable
 * form, except in compliance with the terms and conditions of the RPL.
 *
 * All software distributed under the RPL is provided strictly on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND
 * LICENSOR HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT
 * LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE, QUIET ENJOYMENT, OR NON-INFRINGEMENT. See the RPL for specific
 * language governing rights and limitations under the RPL.
 *
 * The User-Visible Attribution Notice below, when provided, must appear in each
 * user-visible display as defined in Section 6.4 (d):
 * 
 * Initial art work including: design, logic, programming, and graphics are
 * Copyright (C) 2009 Kaity G. B. and released under the RPL where sapplicable.
 * All materials not covered under the terms of the RPL are all still
 * Copyright (C) 2009 Kaity G. B. and released under the terms of the
 * Creative Commons Non-Comercial, Attribution, Share-A-Like version 3.0 US license.
 * 
 * Any & all data stored by this Software created, generated and/or uploaded by any User
 * and any data gathered by the Software that connects back to the User.  All data stored
 * by this Software is Copyright (C) of the User the data is connected to.
 * Users may lisences their data under the terms of an OSI approved or Creative Commons
 * license.  Users must be allowed to select their choice of license for each piece of data
 * on an individual bases and cannot be blanketly applied to all of the Users.  The User may
 * select a default license for their data.  All of the Software's data pertaining to each
 * User must be fully accessible, exportable, and deletable to that User.
 */

/********************************************************************************
 *                      My art, code, & programming.                            *
 ********************************************************************************/
#ifndef __MY_GOBJECT_EXTENDED_H__
#define __MY_GOBJECT_EXTENDED_H__



/********************************************************************************
 *      Project, system, & library headers.  eg #include <gdk/gdkkeysyms.h>     *
 ********************************************************************************/
#define _GNU_SOURCE
#define _THREAD_SAFE

#include <glib.h>
#include <gtk/gtk.h>


/********************************************************************************
 *        Methods, macros, constants, objects, structs, and enum typedefs       *
 ********************************************************************************/
G_BEGIN_DECLS

#define TYPE_MY_GOBJECT			(my_gobject_get_type())
#define MY_GOBJECT(o)			(G_TYPE_CHECK_INSTANCE_CAST((o), TYPE_MY_GOBJECT, MyGObject))
#define MY_GOBJECT_CLASS(k)		(G_TYPE_CHECK_CLASS_CAST((k), TYPE_MY_GOBJECT, MyGObjectClass))
#define IS_MY_GOBJECT(o)		(G_TYPE_CHECK_INSTANCE_TYPE((o), TYPE_MY_GOBJECT))
#define IS_MY_GOBJECT_CLASS(k)		(G_TYPE_CHECK_CLASS_TYPE((k), TYPE_MY_GOBJECT))
#define MY_GOBJECT_GET_CLASS(o)		(G_TYPE_INSTANCE_GET_CLASS((o), TYPE_MY_GOBJECT, MyGObjectClass))

typedef struct _MyGObject      MyGObject;
typedef struct _MyGObjectClass MyGObjectClass;
typedef struct _MyGObjectPrivate  MyGObjectPrivate;

struct _MyGObject {
	/*GObject            parent;*/
	GtkWidget            parent;
};

struct _MyGObjectClass {
	/*GObjectClass       parent_class;*/
	GtkWidgetClass       parent_class;
};


GType my_gobject_get_type(void) G_GNUC_CONST;
MyGObject *my_gobject_new(const gchar *uri);
void my_gobject_null_and_void_catch_all_method(MyGObject *my_gobject);


/********************************************************************************
 *       my "catch all" method to call any static methods because:              *
 *             - they may not be in use atm.                                    *
 *             - they're temporarally not being called.                         *
 *             - signal handlers as defined in my GtkBuildable UI.              *
 ********************************************************************************/
void my_gobject_null_and_void_catch_all_method(MyGObject *my_gobject);



/********************************************************************************
 *       prototypes for methods, handlers, callbacks, function, & etc           *
 ********************************************************************************/
GtkWidget *my_gobject_get_widget(MyGObject *my_gobject);
const gchar *my_gobject_get_uri(MyGObject *my_gobject);
const gchar *my_gobject_get_title(MyGObject *my_gobject);

gint my_gobject_get_page(MyGObject *my_gobject);
void my_gobject_set_page(MyGObject *my_gobject, gint page);

void my_gobject_start(MyGObject *my_gobject);
gboolean my_gobject_refresh(MyGObject *my_gobject);

void my_gobject_append(MyGObject *my_gobject, gulong id, gulong age, gchar *title, const gchar *image_filename, gpointer *pointer);



G_END_DECLS
#endif /* __MY_GOBJECT_EXTENDED_H__ */
/********************************************************************************
 *                                    eof                                       *
 ********************************************************************************/

