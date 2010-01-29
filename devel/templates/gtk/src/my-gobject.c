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
#define _GNU_SOURCE
#define _THREAD_SAFE



/********************************************************************************
 *      Project, system, & library headers.  eg #include <gdk/gdkkeysyms.h>     *
 ********************************************************************************/
#include <glib.h>
#include <glib/gi18n.h>
#include <glib/gprintf.h>
#include <gtk/gtk.h>
#include <gdk/gdkkeysyms.h>

#include "config.h"
#include "program.h"

#include "my-gobject.h"


/********************************************************************************
 *        typedefs: methods, macros, constants, objects, structs, and enums     *
 ********************************************************************************/
#define	GET_PRIVATE(obj)	(G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_MY_GOBJECT, MyGObjectPrivate))

struct _MyGObjectPrivate {
	guint			timeout_id;
	
	gint			index;
	gint			total;
};


/********************************************************************************
 *              Debugging information static objects, and local defines         *
 ********************************************************************************/
#define DEBUG_DOMAINS "{Stuff}:GtkBuilder:GtkBuildable:Settings:Setup:Start-Up:MyGObject.c"
#include "debug.h"

#define GtkBuilderUI "my-gobject"


/********************************************************************************
 *               object methods, handlers, callbacks, & etc.                    *
 ********************************************************************************/
static void my_gobject_class_init(MyGObjectClass *klass);
static void my_gobject_init(MyGObject *my_gobject);
static void my_gobject_finalize(MyGObject *my_gobject);

G_DEFINE_TYPE(MyGObject, my_gobject, G_TYPE_OBJECT);

static void my_gobject_setup(MyGObject *my_gobject);

/********************************************************************************
 *              creativity...art, beauty, fun, & magic...programming            *
 ********************************************************************************/
/* BEGIN: GObject core methods. */
static void my_gobject_class_init(MyGObjectClass *klass){
	GObjectClass	*object_class=G_OBJECT_CLASS(klass);
	
	object_class->finalize=(GObjectFinalizeFunc)my_gobject_finalize;
	
	g_type_class_add_private(object_class, sizeof(MyGObjectPrivate));
}/* my_gobject_class_init */

static void my_gobject_init(MyGObject *my_gobject){
	MyGObjectPrivate *this=GET_PRIVATE(my_gobject);
	
	my_gobject_setup(my_gobject);
	this->timeout_id=this->index=this->total=0;
	g_object_set(my_gobject, "expand", TRUE, "fill", TRUE, NULL);
	g_signal_connect(my_gobject, "grab-focus", G_CALLBACK(my_gobject_grab_focus_cb), my_gobject);
}/* my_gobject_init(); */

MyGObject *my_gobject_new(void){
	return g_object_new(TYPE_MY_GOBJECT, NULL);
}/*my_gobject_new();*/

static void my_gobject_finalize(MyGObject *my_gobject){
	MyGObjectPrivate *this=GET_PRIVATE(my_gobject);
	
	program_timeout_remove(&this->timeout_id, "MyGObject configuration timeout");
	
	G_OBJECT_CLASS(my_gobject_parent_class)->finalize(G_OBJECT(my_gobject));
}/* my_gobject_finalized(my_gobjects); */


/*BEGIN: Custom MyGObject methods.*/
/********************************************************************************
 *       my "catch all" method to call any static methods because:              *
 *             - they may not be in use atm.                                    *
 *             - they're temporarally not being called.                         *
 *             - signal handlers as defined in my GtkBuildable UI.              *
 ********************************************************************************/
void my_gobject_null_and_void_catch_all_method(MyGObject *my_gobject){
	if(!( my_gobject && IS_MY_GOBJECT(my_gobject) ))	return;
}/*my_gobject_null_and_void_catch_all_method(my_gobject);*/

static void my_gobject_setup(MyGObject *my_gobject){
	if(!( my_gobject && IS_MY_GOBJECT(my_gobject) )) return;
	MyGObjectPrivate *this=GET_PRIVATE(my_gobject);
	
}/*uberChick_sexy_entry_completion_setup(uberChick_sexy_entry_completion);*/


void my_gobject_set_int_property(MyGObject *my_gobject, gint value){
	if(!( my_gobject && IS_MY_GOBJECT(my_gobject) ))	return;
	GET_PRIVATE(my_gobject)->value=value;
}/*my_gobject_set_page(my_gobject, 0);*/

gint my_gobject_get_int_property(MyGObject *my_gobject){
	if(!( my_gobject && IS_MY_GOBJECT(my_gobject) ))	return -1;
	return GET_PRIVATE(my_gobject)->value;
}/*my_gobject_get_page(my_gobject);*/


/********************************************************************************
 *                                    eof                                       *
 ********************************************************************************/

