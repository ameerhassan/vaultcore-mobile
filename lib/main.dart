import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/core/theme/app_theme.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/bloc/banking_bloc.dart';
import 'package:flutter_enterprise_clean_architecture/features/banking/presentation/pages/banking_dashboard_page.dart';
import 'package:flutter_enterprise_clean_architecture/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initServiceLocator();
  runApp(const EnterpriseBankingApp());
}

class EnterpriseBankingApp extends StatelessWidget {
  const EnterpriseBankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BankingBloc>(
          create: (_) => di.sl<BankingBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Enterprise Banking Core',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const BankingDashboardPage(),
      ),
    );
  }
}
